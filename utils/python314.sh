#!/bin/bash

set -e

# Ensure uv is on PATH (installed to ~/.local/bin by default)
export PATH="$HOME/.local/bin:$PATH"

if ! command -v uv &>/dev/null; then
    echo "uv is not installed. Run utils/uv.sh first."
    exit 1
fi

if uv python list 2>/dev/null | grep -q "cpython-3\.14"; then
    echo "Python 3.14 is already managed by uv."
    exit 0
fi

echo "Installing Python 3.14 via uv..."
uv python install 3.14

echo "Python 3.14 installed."
echo "Usage:"
echo "  uv run --python 3.14 <script>"
echo "  uv venv --python 3.14"
