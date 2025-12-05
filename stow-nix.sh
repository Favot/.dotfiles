#!/bin/bash
# Script to properly stow the nix directory
# Since ~/.config already exists with other dirs, we handle nix separately

cd "$(dirname "$0")"

# Remove existing symlink if it exists
if [ -L ~/.config/nix ]; then
    rm ~/.config/nix
fi

# Create the symlink
ln -s "$(pwd)/.config/nix" ~/.config/nix

echo "✓ Created ~/.config/nix -> $(pwd)/.config/nix"
