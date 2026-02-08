# vim: set filetype=zsh :

# ==============================================================================
# Environment Variables
# ==============================================================================
export LANG=ja_JP.UTF-8

# 標準的なパスを通しておく (go installやpip install --user用)
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# ==============================================================================
# History Settings
# ==============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# 直前のコマンドの重複を削除
setopt hist_ignore_dups
# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
# 同時に起動したzshの間でヒストリを共有
setopt share_history

# ==============================================================================
# Completion
# ==============================================================================
# 補完機能を有効にする
autoload -Uz compinit
compinit -u

# 補完候補を詰めて表示
setopt list_packed
# 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''

# ==============================================================================
# Options
# ==============================================================================
# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep
# ディレクトリスタック (cd履歴を保存)
DIRSTACKSIZE=1003
setopt AUTO_PUSHD

# 便利なエイリアス (WSL用)
# Windowsのエクスプローラーでカレントディレクトリを開く: 'open .'
alias open='explorer.exe'
# lsの色付け
alias ls='ls --color=auto'
alias ll='ls -alF'

# ==============================================================================
# Prompt & Git Integration
# ==============================================================================
autoload -Uz vcs_info
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{magenta}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{#ffff00}+"
zstyle ':vcs_info:*' formats "%F{cyan}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }

# プロンプト定義
# <GitUser:GitEmail> [User@Host:Path] (GitBranch) $
PROMPT='
<%F{#00bfff}`git config user.name`%f:%F{#00ff00}`git config user.email`%f>
[%B%F{#ff69b4}%n@%m%f%b:%F{#00ffff}%~%f]%F{cyan}$vcs_info_msg_0_%f
%F{yellow}$%f '

# ==============================================================================
# Local Settings (Not tracked by Git)
# ==============================================================================
# APIキーや会社固有の設定は .zshrc.local に記述する
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi