#!/usr/bin/env bash
set -e

echo "=== Removing conflicting files for dotbot installation ==="
echo "Note: All files have been backed up to ~/dotfiles-backup/"
echo ""

# Function to safely remove if exists
safe_remove() {
    local path="$1"
    if [[ -e "$path" ]] || [[ -L "$path" ]]; then
        echo "Removing: $path"
        rm -rf "$path"
    else
        echo "Skipping (not found): $path"
    fi
}

# Remove files that are identical to repo versions
echo "--- Removing identical files ---"
safe_remove "$HOME/.zshenv"
safe_remove "$HOME/.gitconfig"

# Remove directories that will be replaced
echo ""
echo "--- Removing directories to be replaced ---"
safe_remove "$HOME/.config/zsh"
safe_remove "$HOME/.config/sketchybar"
safe_remove "$HOME/.config/aerospace"
safe_remove "$HOME/.config/borders"
safe_remove "$HOME/.config/thefuck"
safe_remove "$HOME/.config/firefox"
safe_remove "$HOME/.config/brew"

# Remove existing Brewfile symlink if it exists
echo ""
echo "--- Removing Brewfile symlink ---"
safe_remove "$HOME/.Brewfile"

echo ""
echo "=== Conflicting files removed ==="
echo "You can now run: ./install"