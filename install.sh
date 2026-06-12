#!/bin/zsh

# Rename target -> target.backup if it exists as a real file (not a symlink)
backup() {
  target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup"
    echo "-----> Moved your old $target config file to $target.backup"
  fi
}

# Symlink file -> link, creating the parent directory if it doesn't exist
symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    mkdir -p "$(dirname "$link")"
    echo "-----> Symlinking your new $link"
    ln -s "$file" "$link"
  fi
}

# === 1. macOS: Homebrew + Brewfile FIRST, so git/gh/code/rbenv/postgres/
#        ghostty/herdr/font exist before any step below relies on them ===
if [[ `uname` =~ "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "-----> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"   # ensure brew is on PATH for this script
  if [ -f "$PWD/Brewfile" ]; then
    echo "-----> Installing packages from Brewfile..."
    brew bundle --file="$PWD/Brewfile"
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

# === 4. Version managers (rbenv comes from the Brewfile). nvm + pyenv install
#        into ~/.nvm and ~/.pyenv; our zprofile/zshrc already source them ===
if [ ! -d "$HOME/.nvm" ]; then
  echo "-----> Installing nvm..."
  git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
  ( cd "$HOME/.nvm" && git checkout "$(git describe --abbrev=0 --tags)" )
fi
if [ ! -d "$HOME/.pyenv" ]; then
  echo "-----> Installing pyenv..."
  curl -fsSL https://pyenv.run | bash
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

# The VS Code cask doesn't put `code` on PATH, so fall back to the app bundle
CODE_BIN="$(command -v code || true)"
[[ -z "$CODE_BIN" && `uname` =~ "Darwin" ]] && CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ -x "$CODE_BIN" ] && [ -f "$PWD/vscode-extensions.txt" ]; then
  echo "-----> Installing VS Code extensions..."
  grep -vE '^[[:space:]]*(#|$)' "$PWD/vscode-extensions.txt" | while read -r ext; do
    "$CODE_BIN" --install-extension "$ext"
  done
fi

# === 7. macOS: SSH config + add the key passphrase to the keychain ===
if [[ `uname` =~ "Darwin" ]]; then
  target=~/.ssh/config
  backup "$target"
  symlink "$PWD/config" "$target"
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

echo "👌 All set! Reloading your shell..."
exec zsh -l   # login shell so .zprofile (env/PATH) loads too; must be last
