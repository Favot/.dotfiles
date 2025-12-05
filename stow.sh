#!/bin/bash
# Unified script to stow all dotfiles
# This will create symlinks from ~/.config/* to ~/.dotfiles/.config/*
# The dotfiles .config directory is the source of truth

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
STOW_PACKAGE=".config"

cd "$DOTFILES_DIR"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: stow is not installed. Please install it first."
    exit 1
fi

echo "📦 Stowing .config directory..."
echo "   Source: $DOTFILES_DIR/$STOW_PACKAGE"
echo "   Target: $CONFIG_DIR"

# Ensure ~/.config exists
mkdir -p "$CONFIG_DIR"

# Get list of items we want to manage from the dotfiles .config directory
MANAGED_ITEMS=($(ls -A "$DOTFILES_DIR/$STOW_PACKAGE" 2>/dev/null || echo ""))

# Remove existing items that we want to manage (if they're not already symlinks to our dotfiles)
for item in "${MANAGED_ITEMS[@]}"; do
    [ -z "$item" ] && continue
    item_path="$CONFIG_DIR/$item"
    
    if [ -e "$item_path" ]; then
        if [ -L "$item_path" ]; then
            # Check if it's already pointing to our dotfiles
            link_target=$(readlink -f "$item_path" 2>/dev/null || readlink "$item_path")
            if [[ "$link_target" == *".dotfiles"* ]]; then
                echo "   ✓ $item already linked correctly"
                continue
            else
                echo "   ⚠ Removing existing symlink: $item"
                rm "$item_path"
            fi
        elif [ -d "$item_path" ] || [ -f "$item_path" ]; then
            # Backup existing item before replacing with symlink
            if [ -e "$DOTFILES_DIR/$STOW_PACKAGE/$item" ]; then
                echo "   ⚠ Backing up existing $item to ${item_path}.backup"
                mv "$item_path" "${item_path}.backup"
            fi
        fi
    fi
done

# Create symlinks for each item
# We do this manually after backing up to ensure it works correctly
for item in "${MANAGED_ITEMS[@]}"; do
    [ -z "$item" ] && continue
    item_path="$CONFIG_DIR/$item"
    dotfiles_item="$DOTFILES_DIR/$STOW_PACKAGE/$item"
    
    # Skip if already linked correctly
    if [ -L "$item_path" ]; then
        link_target=$(readlink -f "$item_path" 2>/dev/null || readlink "$item_path")
        if [[ "$link_target" == *".dotfiles"* ]]; then
            continue
        fi
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -e "$item_path" ] && [ -e "$dotfiles_item" ]; then
        echo "   → Linking $item"
        ln -s "$dotfiles_item" "$item_path"
    fi
done

# Also try using stow for any remaining items (in case manual linking missed something)
echo ""
echo "   Running stow to ensure all symlinks are created..."
stow -d "$DOTFILES_DIR" -t "$HOME" -S "$STOW_PACKAGE" 2>&1 | sed 's/^/   /' || true

echo ""
echo "✓ Successfully stowed .config directory!"
echo ""
echo "To see what's linked:"
echo "  ls -la ~/.config"
echo ""
echo "To unstow (remove symlinks):"
echo "  stow -d $DOTFILES_DIR -t $HOME -D $STOW_PACKAGE"

