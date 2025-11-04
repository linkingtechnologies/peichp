#!/bin/bash
set -euo pipefail

# ---- Arguments ----
ENGINE="${1:-llama.cpp}"
ROOT_DIR="${2:-build}"
LANGUAGE="${3:-en}"
ASSET_FLAVOR="${4:-cpu-x64}"
MODEL_PRESET="${5:-tinystories}"
QUANT="${6:-q3}"

# ---- Cache control ----
USE_CACHE="${USE_CACHE:-off}"
if [[ "$USE_CACHE" == "off" ]]; then
  FORCE_DOWNLOAD=1
else
  unset FORCE_DOWNLOAD || true
fi

# ---- Required tools ----
REQ=("wget" "unzip" "sed" "jq" "find")
for b in "${REQ[@]}"; do
  if ! command -v "$b" >/dev/null; then
    echo "Missing '$b' — install: sudo apt install -y ${REQ[*]}"
    exit 1
  fi
done

# ---- Quant suffix mapping ----
case "$QUANT" in
  q3) QWEN_SUFFIX="q3_k_m"; TINY_SUFFIX="q3_k_m"; TINYSTORIES_SUFFIX="Q2_K" ;;
  q4) QWEN_SUFFIX="q4_k_m"; TINY_SUFFIX="q4_0";  TINYSTORIES_SUFFIX="Q4_K_M" ;;
  *) echo "Invalid quant: $QUANT (use q3|q4)"; exit 1 ;;
esac

# ---- Model presets ----
MODEL_URL="${MODEL_URL:-}"
MODEL_FILE="${MODEL_FILE:-}"

if [[ -z "$MODEL_URL" || -z "$MODEL_FILE" ]]; then
  case "$MODEL_PRESET" in

    tinystories)
      HF_REPO="afrideva/Tinystories-gpt-0.1-3m-GGUF"
      MODEL_FILE="tinystories-gpt-0.1-3m.${TINYSTORIES_SUFFIX}.gguf"
      MODEL_URL="https://huggingface.co/${HF_REPO}/resolve/main/${MODEL_FILE}"
      ;;

    qwen)
      HF_REPO="Qwen/Qwen2.5-1.5B-Instruct-GGUF"
      MODEL_FILE="qwen2.5-1.5b-instruct-${QWEN_SUFFIX}.gguf"
      MODEL_URL="https://huggingface.co/${HF_REPO}/resolve/main/${MODEL_FILE}"
      ;;

    tinyllama)
      HF_REPO="ggml-org/tinyllama-1.1b-1t"
      MODEL_FILE="tinyllama-1.1b-chat-${TINY_SUFFIX}.gguf"
      MODEL_URL="https://huggingface.co/${HF_REPO}/resolve/main/${MODEL_FILE}"
      ;;

    *)
      echo "Unknown model preset: $MODEL_PRESET"
      exit 1
  esac
fi

# ---- Path setup ----
ENGINE_DIR="$ROOT_DIR/ai-engine"

case "$ENGINE" in
  llama.cpp) ENGINE_SUBDIR="llama" ;;
  *) echo "Engine '$ENGINE' not supported yet"; exit 1 ;;
esac

ENGINE_HOME="$ENGINE_DIR/$ENGINE_SUBDIR"
MODELS_DIR="$ENGINE_DIR/models"

CACHE_DIR="cache"
CACHE_BIN="$CACHE_DIR/$ENGINE_SUBDIR"
CACHE_MODELS="$CACHE_DIR/models"

if [ -z "${KEEP_BUILD_DIR:-}" ]; then
    rm -rf "$ROOT_DIR"
else
    echo "Skipping build directory removal because KEEP_BUILD_DIR is set"
fi

mkdir -p "$ENGINE_HOME" "$MODELS_DIR" temp "$CACHE_BIN" "$CACHE_MODELS"

echo ">> Engine:         $ENGINE"
echo ">> Build dir:      $ROOT_DIR"
echo ">> Language:       $LANGUAGE"
echo ">> Asset flavor:   $ASSET_FLAVOR"
echo ">> Model preset:   $MODEL_PRESET ($QUANT)"
echo ">> Model file:     $MODEL_FILE"
echo ">> USE_CACHE:      $USE_CACHE"

# =========================================================
# Download llama.cpp Windows binaries
# =========================================================

if [[ "$ENGINE" == "llama.cpp" ]]; then
  ZIP="llama-win-${ASSET_FLAVOR}.zip"
  ZIP_CACHE="$CACHE_BIN/$ZIP"
  ZIP_LOCAL="temp/$ZIP"

  fetch_release_json() {
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
      wget -qO- --header="Authorization: Bearer $GITHUB_TOKEN" "$1" || true
    else
      wget -qO- "$1" || true
    fi
  }

  resolve_asset_url() {
    json="$(fetch_release_json https://api.github.com/repos/ggml-org/llama.cpp/releases/latest)"
    printf "%s" "$json" \
      | jq -r '.assets[].browser_download_url' \
      | grep -i "win" | grep -i "$ASSET_FLAVOR" | head -1
  }

  if [[ -f "$ZIP_CACHE" && -z "${FORCE_DOWNLOAD:-}" ]]; then
    cp "$ZIP_CACHE" "$ZIP_LOCAL"
  else
    [[ -n "${OFFLINE:-}" ]] && { echo "Offline but no cached llama binary"; exit 1; }
    ASSET_URL="${ASSET_URL:-$(resolve_asset_url)}"
    wget -O "$ZIP_LOCAL" "$ASSET_URL"
    cp "$ZIP_LOCAL" "$ZIP_CACHE"
  fi
  
  
  zip -d "$ZIP_LOCAL" "rpc-server.exe"

  unzip -oq "$ZIP_LOCAL" -d "$ENGINE_HOME"

  SERVER_EXE="$(find "$ENGINE_HOME" -iname '*server*.exe' | head -1)"
  MAIN_EXE="$(find "$ENGINE_HOME" -iname 'main*.exe' | head -1)"

  mkdir -p "$ENGINE_HOME/.bin"
  cp "$SERVER_EXE" "$ENGINE_HOME/.bin/" 2>/dev/null || true
  cp "$MAIN_EXE" "$ENGINE_HOME/.bin/" 2>/dev/null || true

  cp "$ENGINE_HOME/.bin/$(basename "$SERVER_EXE")" "$ENGINE_HOME/llama-server.exe" 2>/dev/null || true
  SERVER_NAME="llama-server.exe"
fi

# =========================================================
# Download GGUF model
# =========================================================
MODEL_CACHE="$CACHE_MODELS/$MODEL_FILE"
MODEL_PATH="$MODELS_DIR/$MODEL_FILE"

if [[ -f "$MODEL_CACHE" && -z "${FORCE_DOWNLOAD:-}" ]]; then
  cp "$MODEL_CACHE" "$MODEL_PATH"
else
  [[ -n "${OFFLINE:-}" ]] && { echo "Offline but model missing in cache"; exit 1; }
  wget -O "$MODEL_PATH" "$MODEL_URL"
  cp "$MODEL_PATH" "$MODEL_CACHE"
fi

# =========================================================
# Create Windows launch scripts
# =========================================================

# start_AI_server.bat (auto-select newest .gguf)
cat > "$ROOT_DIR/start_AI_server.bat" <<BAT
@echo off
setlocal enabledelayedexpansion

rem === Script directory
set "DIR=%~dp0"
set "PORT=8181"
set "MODELS_DIR=%DIR%ai-engine\\models"

echo Searching for newest GGUF in: %MODELS_DIR%
set "MODEL="

for /f "delims=" %%f in ('dir /b /a-d /o-d "%MODELS_DIR%\\*.gguf" 2^>nul') do (
    set "MODEL=%%f"
    goto foundmodel
)

echo [ERROR] No model found in %MODELS_DIR%
exit /b 1

:foundmodel
set "MODEL=%MODELS_DIR%\\%MODEL%"
echo Using model: "%MODEL%"
echo Starting server...

if exist ".\php\RunHiddenConsole.exe" (
.\php\RunHiddenConsole.exe "%DIR%ai-engine\llama\llama-server.exe" -m "%MODEL%" --port %PORT%
) else (
start "" "%DIR%ai-engine\llama\llama-server.exe" -m "%MODEL%" --port %PORT%
)

start http://localhost:%PORT%

echo Server running at http://localhost:%PORT%
BAT

# stop
cat > "$ROOT_DIR/stop_AI_server.bat" <<BAT
@echo off
echo Stopping llama.cpp server...
taskkill /IM llama-server.exe /F >nul 2>&1
echo Done.
BAT

# Italian aliases
if [[ "$LANGUAGE" == "it" ]]; then
  cp "$ROOT_DIR/start_AI_server.bat" "$ROOT_DIR/avvia_server_IA.bat"
  cp "$ROOT_DIR/stop_AI_server.bat" "$ROOT_DIR/ferma_server_IA.bat"
fi

echo
echo "Build complete"
echo
