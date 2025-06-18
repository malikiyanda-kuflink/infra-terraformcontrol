#!/bin/bash

# Check if a directory path was provided as an argument
if [ -z "$1" ]; then
    DIRECTORY_PATH="$(pwd)"
else
    DIRECTORY_PATH="$1"
fi

# Recursively find all subdirectories containing .tf files and run terraform fmt
find "$DIRECTORY_PATH" -type d | while read -r dir; do
    if ls "$dir"/*.tf &>/dev/null; then
        echo "Running terraform fmt in $dir"
        terraform fmt "$dir"
    else
        echo "No .tf files available in $dir"
    fi
done
