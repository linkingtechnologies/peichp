ECHO Starting PHP Embedded server...
.\php\RunHiddenConsole.exe .\php\php.exe -S localhost:8080 -t html

ECHO Exiting.

start http://localhost:8080
EXIT