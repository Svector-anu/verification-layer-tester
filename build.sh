#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check the version of a command
check_version() {
    local cmd=$1
    local required_version=$2
    local version=$($cmd --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [[ $(echo -e "$version\n$required_version" | sort -V | head -n1) != "$required_version" ]]; then
        echo "Error: $cmd version $required_version or higher is required. Found version $version." >&2
        exit 1
    fi
}

# Check for required environment variables
: "${ENV_VAR:?Need to set ENV_VAR}"

# Check for required dependencies
REQUIRED_CMDS=("gcc" "make" "curl")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# Check versions
check_version "gcc" "9.3.0"

# Build steps
echo "Starting build process..."

# Example build step
if ! gcc -o my_program my_program.c; then
    echo "Build failed." >&2
    exit 1
fi

# Run tests
echo "Running tests..."
if ! ./run_tests.sh; then
    echo "Tests failed." >&2
    exit 1
fi

# Package the application
echo "Packaging application..."
if ! tar -czf my_program.tar.gz my_program; then
    echo "Packaging failed." >&2
    exit 1
fi

echo "Build process completed successfully."
