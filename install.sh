#!/bin/zsh

# Rename target -> target.backup if it exists as a real file (not a symlink)
backup() {
  target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup"
    echo "-----> Moved your old $target config file to $target.backup"
  fi
}

# Symlink file -> link (idempotent): no-op if it already points where we want,
# otherwise create the parent dir and (re)point the link — replacing a stale or
# broken symlink so re-runs never error with "File exists".
symlink() {
  file=$1
  link=$2
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$file" ]; then
    return
  fi
  mkdir -p "$(dirname "$link")"
  echo "-----> Symlinking $link"
  ln -sfn "$file" "$link"
}

# --- Log this run to a timestamped file, mirrored live to the terminal ---
LOG_DIR="$HOME/.dotfiles-logs"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
exec 3>&1 4>&2                # save the real stdout/stderr for the handoff
exec > >(tee "$LOG") 2>&1     # mirror everything below into the log
echo "-----> Logging this run to $LOG"

# === 1. Base toolchain FIRST, so git/gh/version-managers/postgres exist before
#        any step below relies on them ===
if [[ `uname` =~ "Darwin" ]]; then
  # macOS: Homebrew + Brewfile (also installs ghostty/herdr/font/VS Code)
  if ! command -v brew >/dev/null 2>&1; then
    echo "-----> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"   # ensure brew is on PATH for this script
  if [ -f "$PWD/Brewfile" ]; then
    echo "-----> Installing packages from Brewfile..."
    brew bundle --file="$PWD/Brewfile"
  fi
elif command -v apt-get >/dev/null 2>&1; then
  # Debian/Ubuntu/WSL: apt (mirrors the Brewfile via the Aptfile)
  echo "-----> Installing packages with apt..."
  sudo apt-get update
  sudo apt-get install -y curl wget   # ensure we can fetch the gh signing key
  # GitHub CLI ships from its own apt repo; add it once.
  if ! command -v gh >/dev/null 2>&1; then
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
  fi
  if [ -f "$PWD/Aptfile" ]; then
    grep -vE '^[[:space:]]*(#|$)' "$PWD/Aptfile" | xargs sudo apt-get install -y
  fi
fi

# === 2. oh-my-zsh (zshrc sources it). Unattended, and keep our own .zshrc ===
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "-----> Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# === 3. External oh-my-zsh plugins (needs git, now installed) ===
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_PLUGINS_DIR/$plugin" ]; then
    echo "-----> Installing zsh plugin '$plugin'..."
    git clone "https://github.com/zsh-users/$plugin" "$ZSH_PLUGINS_DIR/$plugin"
  fi
done

# === 4. Version managers. nvm -> ~/.nvm, pyenv -> ~/.pyenv (zprofile/zshrc
#        already source them). rbenv: Homebrew on macOS, git clone on Linux ===
if [ ! -d "$HOME/.nvm" ]; then
  echo "-----> Installing nvm..."
  git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
  ( cd "$HOME/.nvm" && git checkout "$(git describe --abbrev=0 --tags)" )
fi
if [ ! -d "$HOME/.pyenv" ]; then
  echo "-----> Installing pyenv..."
  curl -fsSL https://pyenv.run | bash
fi
if [[ ! `uname` =~ "Darwin" ]] && [ ! -d "$HOME/.rbenv" ]; then
  echo "-----> Installing rbenv..."
  git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
  git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"
fi

# === 5. Symlink dotfiles to ~/.<name> (backing up any real file first) ===
for name in aliases gitconfig irbrc rspec zprofile zshrc; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup "$target"
    symlink "$PWD/$name" "$target"
  fi
done

# === 6. VS Code settings/keybindings + curated extensions ===
if [[ `uname` =~ "Darwin" ]]; then
  CODE_PATH=~/Library/Application\ Support/Code/User
else
  CODE_PATH=~/.config/Code/User
  [ ! -e "$CODE_PATH" ] && CODE_PATH=~/.vscode-server/data/Machine   # WSL
fi
for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup "$target"
  symlink "$PWD/$name" "$target"
done

# Resolve the `code` CLI. macOS: the cask doesn't add it to PATH, so fall back
# to the app bundle. WSL: it's the Remote-WSL shim, only on PATH once VS Code
# (Windows) + the Remote-WSL extension are installed and the WSL window is open
# — i.e. it's reliably present in VS Code's integrated terminal.
CODE_BIN="$(command -v code || true)"
[[ -z "$CODE_BIN" && `uname` =~ "Darwin" ]] && CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ -x "$CODE_BIN" ] && [ -f "$PWD/vscode-extensions.txt" ]; then
  echo "-----> Installing VS Code extensions..."
  grep -vE '^[[:space:]]*(#|$)' "$PWD/vscode-extensions.txt" | while read -r ext; do
    "$CODE_BIN" --install-extension "$ext"
  done
elif [ -f "$PWD/vscode-extensions.txt" ]; then
  echo "⚠️  'code' CLI not found — skipping VS Code extensions (settings were still linked)."
  if [[ `uname` =~ "Darwin" ]]; then
    echo "    Install VS Code, then re-run: zsh install.sh"
  else
    echo "    On WSL: install VS Code on Windows + the 'Remote - WSL' extension,"
    echo "    then re-run this from VS Code's WSL integrated terminal (where 'code' is on PATH)."
  fi
fi

# === 7. macOS: SSH config + add the key to the keychain ===
# Unlike the other dotfiles we do NOT take over an existing ~/.ssh/config — it
# often holds custom per-host rules/keys, and the repo's `Host *` block would
# change auth for every host. Only symlink when there's no config yet.
if [[ `uname` =~ "Darwin" ]]; then
  if [ ! -e ~/.ssh/config ] && [ ! -L ~/.ssh/config ]; then
    symlink "$PWD/config" ~/.ssh/config
  elif [ -L ~/.ssh/config ] && [ "$(readlink ~/.ssh/config)" = "$PWD/config" ]; then
    : # already linked to the repo — nothing to do
  else
    echo "⚠️  ~/.ssh/config already exists — leaving it untouched."
    echo "    To adopt the repo's keychain settings, merge them from: $PWD/config"
  fi
  [ -f ~/.ssh/id_ed25519 ] && ssh-add --apple-use-keychain ~/.ssh/id_ed25519
fi

# === 8. macOS terminal stack config: Ghostty + herdr ===
if [[ `uname` =~ "Darwin" ]]; then
  backup "$HOME/.config/ghostty/config"
  symlink "$PWD/ghostty/config" "$HOME/.config/ghostty/config"

  # herdr: seed a default config if missing, then wire up agent integrations
  if command -v herdr >/dev/null 2>&1; then
    HERDR_CONFIG="$HOME/.config/herdr/config.toml"
    if [ ! -e "$HERDR_CONFIG" ]; then
      echo "-----> Seeding herdr default config..."
      mkdir -p "$(dirname "$HERDR_CONFIG")"
      herdr --default-config > "$HERDR_CONFIG"
    fi
    echo "-----> Installing herdr agent integrations..."
    herdr integration install claude 2>/dev/null
    herdr integration install copilot 2>/dev/null
  fi
fi

# === 9. WSL: place the WezTerm config on the Windows host. Windows apps can't
#        follow WSL symlinks, so we copy it. WezTerm itself is installed on
#        Windows (e.g. `winget install wez.wezterm`); see the README. ===
WIN_HOME="/mnt/c/Users/gcham"
if [ -d "$WIN_HOME" ] && [ -f "$PWD/wezterm/wezterm.lua" ] && [ ! -e "$WIN_HOME/.wezterm.lua" ]; then
  echo "-----> Copying WezTerm config to $WIN_HOME/.wezterm.lua"
  cp "$PWD/wezterm/wezterm.lua" "$WIN_HOME/.wezterm.lua"
fi

echo "👌 All set! Full log: $LOG"
exec 1>&3 2>&4 3>&- 4>&-   # stop logging (flush the tee) before the handoff
exec zsh -l                # login shell so .zprofile (env/PATH) loads too; must be last
