# Setup the PATH for pyenv binaries and shims
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  alias init='brew services start postgresql && brew services start redis-server &&  && brew services start mongodb-community'
# Else, it's a Linux
else
  alias init='sudo service postgresql start && sudo service redis-server start && sudo chown mongodb:mongodb /var/run/mongod.pid && sudo service mongodb start && sudo service docker start'
fi

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
# Else, it's a Linux
else

fi
