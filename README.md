# 🔧 My Dotfiles for Windows (WSL2)

Windows PCを開発しやすく変えるためのセットアップ手順書。
zshとかwezTermでターミナルカスタマイズしてた人向けの構成。

## 🚀 0. 前提条件 (必要なければスキップ: 1とかはデフォルトで有効になってるかも)

PCを受け取ったらまず確認すること。

1. **BIOS/UEFIの仮想化設定**(追記：BIOSの入り方はPCによって異なるので要注意！)
   - タスクマネージャー > パフォーマンス > CPU > 「仮想化: 有効」になっているか確認。
   - 無効ならBIOS画面（起動時に `F2` or `Del` 連打）で `Intel Virtualization Technology` (または `SVM Mode`) を **Enabled** にする。

2. **WSL2のインストール**
   - PowerShell (管理者) で実行:
     ```powershell
     wsl --install
     ```
   - 再起動後、Ubuntuが立ち上がるのでユーザー名とパスワードを設定。

3. **WezTermのインストール**
   - [WezTerm公式サイト](https://wezfurlong.org/wezterm/install/windows.html) からWindows版をインストール。
   - ※ `Windows Terminal` でも代用可だが、WezTerm推奨。

4. **Nerd Fontsのインストール（WezTermのタブ装飾に必要）**
   - [Nerd Fonts](https://www.nerdfonts.com/font-downloads) から好みのフォントをダウンロード（例: JetBrainsMono Nerd Font）。
   - ダウンロードしたzipを展開し、`.ttf` ファイルを右クリック →「すべてのユーザー用にインストール」。
   - WezTermの設定に以下を追加:
     ```lua
     config.font = wezterm.font("JetBrainsMono Nerd Font")
     ```
   - ※ Nerd Fontsを入れないとタブの三角矢印（▶◀）が文字化けする。

---

## 🛠 1. WSL初期セットアップ (Ubuntu側)

WezTerm (またはUbuntuアプリ) を開き、以下の手順を実行。

### 1-1. パッケージ更新 & zshインストール
Ubuntuはデフォルトがbashなので、zshに入れ替える。

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install zsh git curl -y

# デフォルトシェルをzshに変更 (パスワード入力)
chsh -s $(which zsh)
```

※ 一度ターミナルを再起動して、プロンプトが変わっていることを確認。

### 1-2. Interop設定 (Windows連携の有効化)
code . や cursor . コマンドを使えるようにするため、システム設定を追加。

```bash
# /etc/wsl.conf を作成/編集
sudo nano /etc/wsl.conf
```

▼ 記述内容:

```
[interop]
enabled = true
appendWindowsPath = true
```

保存 (Ctrl+X -> Y -> Enter) したら、PowerShell で以下を実行してWSLを再起動。

```PowerShell
wsl --shutdown
```

## 📦 2. Dotfilesのインストール
GitHubから設定ファイルをダウンロードし、シンボリックリンクを貼る。

```bash
# 1. リポジトリをクローン
git clone https://github.com/shayate811/dotfiles.git ~/dotfiles

# 2. 既存の.zshrcがあれば退避 (念のため)
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup

# 3. シンボリックリンク作成 (実体はdotfiles、配置はホーム)
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# 4. 設定反映
source ~/.zshrc
```

### WezTerm設定の配置 (Windows側で実行)

WezTermの設定はWindows側に配置する。PowerShellで実行:

```powershell
# WezTerm設定ディレクトリ作成
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\wezterm"

# dotfilesからシンボリックリンク作成 (要管理者権限)
# ※ dotfilesのパスは実際のクローン先に合わせる
$dotfiles = "$env:USERPROFILE\dotfiles"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm\wezterm.lua" -Target "$dotfiles\wezterm\wezterm.lua"
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm\keybinds.lua" -Target "$dotfiles\wezterm\keybinds.lua"
```

## 🔑 3. Git & SSH設定
GitHubと通信するための鍵を作成する。

### 3-1. SSH鍵の生成 (Ed25519)

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# 質問はすべて Enter でOK
```

### 3-2. GitHubへの登録
1. 公開鍵をコピー:

```bash
cat ~/.ssh/id_ed25519.pub
```

2. Github SSH Keys にアクセスし「New SSH key」で貼り付け。

### 3-3. 接続テスト & ユーザー設定

```bash
# 接続確認 (Hi user! と出ればOK)
ssh -T git@github.com

# Gitユーザー設定 (初回のみ必須)
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

## 🏢 4. 会社用/プロジェクト固有設定 (.zshrc.local)
APIキーや社内プロキシ設定など、GitHubに公開してはいけない情報はローカルファイルに記述する。 このファイルは Git管理しないこと。

```bash
# ファイル作成
touch ~/.zshrc.local
```

## ✅ トラブルシューティング

Q. ls の色がそのままっぽいんだけど？

A. wsl --install 直後はUbuntuが認識されていない場合がある。VS Code/WezTermを再起動し、プロファイルが「Ubuntu」になっているか確認。

Q. Exec format error で cursor コマンドが動かない

A. wsl.conf の設定漏れか、WSLが再起動できていない。PowerShellで wsl --shutdown を試す。