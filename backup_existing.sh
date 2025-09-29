#!/usr/bin/env bash
set -e

# Create timestamped backup directory
BACKUP_DIR="$HOME/dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in: $BACKUP_DIR"

# Function to backup if file/directory exists
backup_if_exists() {
    local source="$1"
    local dest="$2"

    if [[ -e "$source" ]] || [[ -L "$source" ]]; then
        echo "Backing up: $source -> $dest"
        mkdir -p "$(dirname "$dest")"
        cp -R "$source" "$dest" 2>/dev/null || true
    else
        echo "Skipping (not found): $source"
    fi
}

echo "=== Backing up existing dotfiles and configurations ==="

# Backup root level dotfiles
backup_if_exists "$HOME/.zshenv" "$BACKUP_DIR/home/.zshenv"
backup_if_exists "$HOME/.gitconfig" "$BACKUP_DIR/home/.gitconfig"
backup_if_exists "$HOME/.Brewfile" "$BACKUP_DIR/home/.Brewfile"
backup_if_exists "$HOME/.zshrc" "$BACKUP_DIR/home/.zshrc"
backup_if_exists "$HOME/.vimrc" "$BACKUP_DIR/home/.vimrc"

# Backup .config directories that will be replaced
backup_if_exists "$HOME/.config/zsh" "$BACKUP_DIR/config/zsh"
backup_if_exists "$HOME/.config/sketchybar" "$BACKUP_DIR/config/sketchybar"
backup_if_exists "$HOME/.config/aerospace" "$BACKUP_DIR/config/aerospace"
backup_if_exists "$HOME/.config/borders" "$BACKUP_DIR/config/borders"
backup_if_exists "$HOME/.config/thefuck" "$BACKUP_DIR/config/thefuck"
backup_if_exists "$HOME/.config/firefox" "$BACKUP_DIR/config/firefox"
backup_if_exists "$HOME/.config/brew" "$BACKUP_DIR/config/brew"

# Backup other important dotfiles that might exist
backup_if_exists "$HOME/.bashrc" "$BACKUP_DIR/home/.bashrc"
backup_if_exists "$HOME/.bash_profile" "$BACKUP_DIR/home/.bash_profile"

echo ""
echo "=== Backup Summary ==="
echo "Backup location: $BACKUP_DIR"
echo "Files backed up:"
find "$BACKUP_DIR" -type f | sed "s|$BACKUP_DIR/||" | sort

echo ""
echo "=== Creating restoration script ==="
cat > "$BACKUP_DIR/restore.sh" << 'EOL'
#!/usr/bin/env bash
set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Restoring from: $BACKUP_DIR"

# Function to restore if backup exists
restore_if_exists() {
    local backup_file="$1"
    local target="$2"

    if [[ -e "$backup_file" ]]; then
        echo "Restoring: $backup_file -> $target"
        mkdir -p "$(dirname "$target")"
        rm -rf "$target" 2>/dev/null || true
        cp -R "$backup_file" "$target"
    fi
}

echo "=== Restoring dotfiles and configurations ==="

# Restore root level dotfiles
restore_if_exists "$BACKUP_DIR/home/.zshenv" "$HOME/.zshenv"
restore_if_exists "$BACKUP_DIR/home/.gitconfig" "$HOME/.gitconfig"
restore_if_exists "$BACKUP_DIR/home/.Brewfile" "$HOME/.Brewfile"
restore_if_exists "$BACKUP_DIR/home/.zshrc" "$HOME/.zshrc"
restore_if_exists "$BACKUP_DIR/home/.vimrc" "$HOME/.vimrc"
restore_if_exists "$BACKUP_DIR/home/.bashrc" "$HOME/.bashrc"
restore_if_exists "$BACKUP_DIR/home/.bash_profile" "$HOME/.bash_profile"

# Restore .config directories
restore_if_exists "$BACKUP_DIR/config/zsh" "$HOME/.config/zsh"
restore_if_exists "$BACKUP_DIR/config/sketchybar" "$HOME/.config/sketchybar"
restore_if_exists "$BACKUP_DIR/config/aerospace" "$HOME/.config/aerospace"
restore_if_exists "$BACKUP_DIR/config/borders" "$HOME/.config/borders"
restore_if_exists "$BACKUP_DIR/config/thefuck" "$HOME/.config/thefuck"
restore_if_exists "$BACKUP_DIR/config/firefox" "$HOME/.config/firefox"
restore_if_exists "$BACKUP_DIR/config/brew" "$HOME/.config/brew"

echo "=== Restoration complete ==="
EOL

chmod +x "$BACKUP_DIR/restore.sh"

echo "Restoration script created: $BACKUP_DIR/restore.sh"
echo ""
echo "=== Backup complete! ==="
echo "To restore your original files, run: $BACKUP_DIR/restore.sh"