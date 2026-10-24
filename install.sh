#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Dotfiles Deployment Script
# Safely links or copies application configurations to $HOME
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "==> Deploying dotfiles from: $DOTFILES_DIR"

backup_and_copy() {
  local src="$1"
  local dest="$2"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
    echo "  [backup] $dest -> $BACKUP_DIR/"
    cp -a "$dest" "$BACKUP_DIR/$(dirname "${dest#$HOME/}")/"
  fi

  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "  [deployed] $dest"
}

# 1. ~/.config applications
echo "==> Deploying ~/.config..."
mkdir -p "$HOME/.config"
for item in "$DOTFILES_DIR/.config"/*; do
  [ -e "$item" ] || continue
  name="$(basename "$item")"
  backup_and_copy "$item" "$HOME/.config/$name"
done

# 2. ~/.local/bin helpers
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
  echo "==> Deploying ~/.local/bin helpers..."
  mkdir -p "$HOME/.local/bin"
  for s in "$DOTFILES_DIR/.local/bin"/*; do
    [ -e "$s" ] || continue
    name="$(basename "$s")"
    backup_and_copy "$s" "$HOME/.local/bin/$name"
    chmod +x "$HOME/.local/bin/$name"
  done
fi

# 3. VSCodium extension
if [ -d "$DOTFILES_DIR/.vscode-oss/extensions" ]; then
  echo "==> Deploying VSCodium extensions..."
  mkdir -p "$HOME/.vscode-oss/extensions"
  for ext in "$DOTFILES_DIR/.vscode-oss/extensions"/*; do
    [ -e "$ext" ] || continue
    name="$(basename "$ext")"
    backup_and_copy "$ext" "$HOME/.vscode-oss/extensions/$name"
  done
fi

# 4. Root dotfiles
echo "==> Deploying root dotfiles..."
for dot in .tmux.conf .bashrc .bash_profile; do
  if [ -f "$DOTFILES_DIR/$dot" ]; then
    backup_and_copy "$DOTFILES_DIR/$dot" "$HOME/$dot"
  fi
done

# 5. Wallpapers
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
  echo "==> Deploying wallpapers..."
  mkdir -p "$HOME/Pictures/Wallpapers"
  cp -a "$DOTFILES_DIR/wallpapers"/* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

echo ""
echo "✨ Dotfiles deployed successfully!"
if [ -d "$BACKUP_DIR" ]; then
  echo "ℹ️  Existing configs were backed up to: $BACKUP_DIR"
fi
