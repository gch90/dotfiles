# pyenv binaries + shims (before anything that relies on them)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

# Homebrew
[[ `uname` =~ "Darwin" ]] && eval $(/opt/homebrew/bin/brew shellenv)

# --- Environment & PATH for login shells (inherited by GUI apps like VS Code) ---

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# `--wait` blocks `code` until the tab closes (needed for git/bundler editors)
export BUNDLER_EDITOR="code --wait"
export EDITOR="code --wait"

export PYTHONBREAKPOINT=ipdb.set_trace

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# No relative ./bin or ./node_modules/.bin on PATH — a malicious repo could
# shadow system commands. Use `bundle exec`; npm/pnpm resolve node_modules/.bin.
export PATH="${PATH}:/usr/local/sbin"

if [[ `uname` =~ "Darwin" ]]; then
  # macOS
  export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
  esac

  export PATH="$HOME/.codeium/windsurf/bin:$PATH"   # Windsurf
else
  # Linux / WSL
  export PATH="$HOME/.npm-global/bin:$PATH"
  [[ -n "$GEM_HOME" ]] && export PATH="$PATH:$GEM_HOME/bin"

  # open WSL browser links in Windows-side Chrome
  export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
  export GH_BROWSER="'/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'"

  # re-add Windows VS Code bin (PAM resets PATH once systemd is enabled)
  [[ -d "/mnt/c/Users/gcham/AppData/Local/Programs/Microsoft VS Code/bin" ]] && \
    export PATH="$PATH:/mnt/c/Users/gcham/AppData/Local/Programs/Microsoft VS Code/bin"
fi

# nvm in login shells too, so GUI apps resolve nvm's node; after brew shellenv so it wins on PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
