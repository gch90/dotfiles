# Setup the PATH for pyenv binaries and shims
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  # alias init='brew services start postgresql@15 && brew services start mongodb-community'
# Else, it's a Linux
else
  # alias init='sudo service postgresql start && sudo touch /var/run/mongod.pid && sudo chown mongodb:mongodb /var/run/mongod.pid && sudo service mongodb start && sudo service docker start'
fi

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
# Else, it's a Linux
else

fi

# --- Environment & PATH (login shell, inherited by GUI apps) ---
# Moved here from .zshrc so GUI-launched apps (VS Code and its extensions /
# integrated terminal) see them — GUI apps inherit the *login* environment,
# not .zshrc. Interactive-only bits (prompt, aliases, direnv/sdkman hooks)
# stay in .zshrc. Child shells inherit these, so nested `zsh` still has them.

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Default editor — `--wait` makes `code` block until the tab closes, so git
# (commit/rebase) and bundler EDITOR flows work; child processes inherit it.
export BUNDLER_EDITOR="code --wait"
export EDITOR="code --wait"

# Default Python debugger (used by `breakpoint()`)
export PYTHONBREAKPOINT=ipdb.set_trace

# Generic user bin dirs
export PATH="$HOME/.poetry/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# We intentionally do NOT add relative ./bin or ./node_modules/.bin to PATH —
# running binaries from the current directory lets a malicious repo shadow
# system commands. Use `bundle exec` for Ruby binstubs; npm/pnpm resolve their
# own ./node_modules/.bin.
export PATH="${PATH}:/usr/local/sbin"

# Platform-specific tool paths
if [[ `uname` =~ "Darwin" ]]; then
  # --- macOS only ---
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

  # pnpm
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  # Windsurf
  export PATH="$HOME/.codeium/windsurf/bin:$PATH"
else
  # --- Linux / WSL only ---
  export PATH="$HOME/.npm-global/bin:$PATH"
  [[ -n "$GEM_HOME" ]] && export PATH="$PATH:$GEM_HOME/bin"

  # Open browser links from WSL in the Windows-side Chrome
  export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
  export GH_BROWSER="'/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'"

  # WSL: the Windows VS Code `bin` dir is no longer auto-appended to PATH once
  # systemd is enabled (PAM resets PATH from /etc/environment), so add it back.
  [[ -d "/mnt/c/Users/gcham/AppData/Local/Programs/Microsoft VS Code/bin" ]] && \
    export PATH="$PATH:/mnt/c/Users/gcham/AppData/Local/Programs/Microsoft VS Code/bin"
fi

# Load nvm in login shells too (not just interactive .zshrc), so GUI apps —
# VS Code and all its extensions — resolve the nvm default node instead of Homebrew's.
# Sourced after brew shellenv so nvm's bin is prepended last and wins on PATH.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
