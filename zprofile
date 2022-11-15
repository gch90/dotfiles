# Setup the PATH for pyenv binaries and shims
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
type -a pyenv > /dev/null && eval "$(pyenv init --path)"

alias init='brew services start postgresql@14 && brew services start redis && brew services start elasticsearch-full && brew services start mongodb-community'

eval $(/opt/homebrew/bin/brew shellenv)

