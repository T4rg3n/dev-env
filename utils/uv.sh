#!/bin/bash

set -e

if command -v uv &>/dev/null; then
    echo "uv is already installed: $(uv --version)"
    exit 0
fi

echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv available in the current shell session
export PATH="$HOME/.local/bin:$PATH"

echo "uv installed: $(uv --version)"
echo "Add the following to your shell profile if not already present:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
