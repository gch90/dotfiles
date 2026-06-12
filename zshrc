ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"

export DEFAULT_USER=$USER

# pyenv (Python version manager)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if type -a pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)" 2>/dev/null   # no-op unless pyenv-virtualenv is installed
  RPROMPT+='[🐍 $(pyenv_prompt_info)]'
fi

# oh-my-zsh plugins
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting zsh-autosuggestions history-substring-search colorize pyenv poetry)
# ssh-agent only off macOS (macOS's Keychain agent already auto-loads keys)
[[ `uname` =~ "Darwin" ]] || plugins+=(ssh-agent)

export HOMEBREW_NO_ANALYTICS=1
ZSH_DISABLE_COMPFIX=true   # skip insecure-directory warnings

source "${ZSH}/oh-my-zsh.sh"
unalias rm # no interactive rm (from common-aliases)
unalias lt # keep `lt` for localtunnel

# rbenv (Ruby version manager)
export PATH="${HOME}/.rbenv/bin:${PATH}" # needed on Linux/WSL
type -a rbenv >/dev/null && eval "$(rbenv init -)"

# nvm: zprofile sources it for login/GUI shells; guard so interactive shells don't double-source
export NVM_DIR="$HOME/.nvm"
command -v nvm >/dev/null || { [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; }
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Auto-run `nvm use` in directories with a .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &>/dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm >/dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm >/dev/null && load-nvmrc

# Environment & PATH live in .zprofile (so GUI apps inherit them); only
# interactive shell integration stays here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# direnv hooks the live shell, so it loads here rather than .zprofile
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# SDKMAN must stay last
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
