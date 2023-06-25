# Setup the PATH for pyenv binaries and shims
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
<<<<<<< HEAD
  alias init='brew services start postgresql@14 && brew services start redis && brew services start mongodb-community'
  # brew services start elasticsearch-full
# Else, it's a Linux
else
  alias init='sudo service postgreslql start && service redis start && sudo service elasticsearch-full start && sudo service mongodb start'
=======
  alias init='brew services start postgresql && brew services start redis-server && brew services start mongodb-community'
# Else, it's a Linux
else
  alias init='sudo service postgresql start && sudo service redis-server start && sudo touch /var/run/mongod.pid && sudo chown mongodb:mongodb /var/run/mongod.pid && sudo service mongodb start && sudo service docker start'
>>>>>>> 20b6a642a119b67de4c3994b13d0422d18ce1880
fi

# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  eval $(/opt/homebrew/bin/brew shellenv)
# Else, it's a Linux
else

fi
