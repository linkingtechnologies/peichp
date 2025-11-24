#!/bin/bash

echo "Starting PHP embedded server..."

./php/bin/php -S localhost:8080 -t html &

PHP_PID=$!

echo "PHP server running with PID $PHP_PID"

xdg-open "http://localhost:8080"

echo "Exiting."
