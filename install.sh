#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# ------------------------------------------------------------------ helpers --
info()    { echo "[INFO]  $*"; }
success() { echo "[OK]    $*"; }
warn()    { echo "[WARN]  $*"; }
error()   { echo "[ERROR] $*" >&2; exit 1; }

symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    warn "backed up existing $(basename "$dst") → $BACKUP_DIR/"
  fi
  ln -sf "$src" "$dst"
  success "linked $dst → $src"
}

# ------------------------------------------------------------------- guards --
if [ -z "${WSL_DISTRO_NAME:-}" ] && ! grep -qi microsoft /proc/version 2>/dev/null; then
  error "このスクリプトはWSL2環境での実行を想定しています"
fi

info "dotfiles dir : $DOTFILES_DIR"
info "backup dir   : $BACKUP_DIR (必要な場合のみ作成)"
echo

# ------------------------------------------------------------------- WSL側 --
info "=== WSL (Linux) side ==="

symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

if [ ! -f "$HOME/.zshrc.local" ]; then
  touch "$HOME/.zshrc.local"
  success "created empty ~/.zshrc.local (APIキー等はここに記述)"
else
  info "~/.zshrc.local は既に存在 → スキップ"
fi

# /etc/wsl.conf (要 sudo)
if [ -f "$DOTFILES_DIR/wsl/wsl.conf" ]; then
  if sudo cp "$DOTFILES_DIR/wsl/wsl.conf" /etc/wsl.conf; then
    success "deployed /etc/wsl.conf"
    warn "/etc/wsl.conf を変更しました。反映には 'wsl --shutdown' が必要です"
  fi
fi

# -------------------------------------------------------------- Windows側 --
info ""
info "=== Windows side (WezTerm) ==="

WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || true)

if [ -z "$WIN_USER" ]; then
  warn "Windowsユーザー名を取得できませんでした。WezTermの設定は手動で配置してください:"
  warn "  \$USERPROFILE\\.config\\wezterm\\wezterm.lua"
  warn "  \$USERPROFILE\\.config\\wezterm\\keybinds.lua"
else
  WEZTERM_DIR="/mnt/c/Users/$WIN_USER/.config/wezterm"
  mkdir -p "$WEZTERM_DIR"
  symlink "$DOTFILES_DIR/wezterm/wezterm.lua"  "$WEZTERM_DIR/wezterm.lua"
  symlink "$DOTFILES_DIR/wezterm/keybinds.lua" "$WEZTERM_DIR/keybinds.lua"
fi

echo
success "=== セットアップ完了 ==="
info "zshを再起動して設定を反映: exec zsh"
