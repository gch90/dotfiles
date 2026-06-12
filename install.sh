#!/bin/zsh

# Rename target -> target.backup if it exists as a real file (not a symlink)
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "-----> Symlinking your new $link"
    ln -s $file $link
  fi
}

# symlink for ~/.config XDG paths: ensure parent dir exists, then back up + link
symlink_config() {
  file=$1
  link=$2
  mkdir -p "$(dirname "$link")"
  backup "$link"
  symlink "$file" "$link"
}

# Symlink each dotfile to ~/.<name>, backing up any existing real file first
for name in aliases gitconfig irbrc rspec zprofile zshrc; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup $target
    symlink $PWD/$name $target
  fi
done

# Install the external oh-my-zsh plugins. Each is guarded independently so a
# partial install (one present, one missing) still gets completed.
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [ ! -d "$ZSH_PLUGINS_DIR/$plugin" ]; then
    echo "-----> Installing zsh plugin '$plugin'..."
    git clone "https://github.com/zsh-users/$plugin" "$ZSH_PLUGINS_DIR/$plugin"
  fi
done

# Symlink VS Code settings + keybindings (path differs by platform)
if [[ `uname` =~ "Darwin" ]]; then
  CODE_PATH=~/Library/Application\ Support/Code/User
else
  CODE_PATH=~/.config/Code/User
  [ ! -e $CODE_PATH ] && CODE_PATH=~/.vscode-server/data/Machine   # WSL
fi

for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup $target
  symlink $PWD/$name $target
done

# Install the curated VS Code extensions (skips comments and blank lines)
if command -v code >/dev/null 2>&1 && [ -f "$PWD/vscode-extensions.txt" ]; then
  echo "-----> Installing VS Code extensions..."
  grep -vE '^[[:space:]]*(#|$)' "$PWD/vscode-extensions.txt" | while read -r ext; do
    code --install-extension "$ext"
  done
fi

# macOS: symlink SSH config and add the key passphrase to the keychain
if [[ `uname` =~ "Darwin" ]]; then
  target=~/.ssh/config
  backup $target
  symlink $PWD/config $target
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
fi

# --- macOS terminal & multi-agent stack (Ghostty + herdr) ---
if [[ `uname` =~ "Darwin" ]]; then
  # Bootstrap Homebrew if it isn't installed yet (fresh Mac).
  if ! command -v brew >/dev/null 2>&1; then
    echo "-----> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # Install the terminal stack from the Brewfile (ghostty, herdr, font).
  if [ -f "$PWD/Brewfile" ]; then
    echo "-----> Installing terminal stack from Brewfile..."
    brew bundle --file="$PWD/Brewfile"
  fi

  # Ghostty config -> ~/.config/ghostty/config
  symlink_config "$PWD/ghostty/config" "$HOME/.config/ghostty/config"

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

exec zsh   # must be last — exec replaces this process, nothing below runs
