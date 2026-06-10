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

# Load nvm in login shells too (not just interactive .zshrc), so GUI apps —
# VS Code and all its extensions — resolve the nvm default node instead of Homebrew's.
# Sourced after brew shellenv so nvm's bin is prepended last and wins on PATH.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
