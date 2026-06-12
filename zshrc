ZSH=$HOME/.oh-my-zsh

# You can change the theme with another one from https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

export DEFAULT_USER=$USER

# Load pyenv (to manage your Python versions)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if type -a pyenv >/dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)" 2>/dev/null   # only works if pyenv-virtualenv is installed
  RPROMPT+='[🐍 $(pyenv_prompt_info)]'
fi

# Useful oh-my-zsh plugins for Le Wagon bootcamps
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting zsh-autosuggestions history-substring-search colorize pyenv poetry)
# ssh-agent: only off macOS. macOS has a launchd/Keychain-backed agent that
# auto-loads keys (`ssh-add --apple-use-keychain`), so the plugin is redundant
# there; on Linux/WSL it usefully starts an agent and loads your keys.
[[ `uname` =~ "Darwin" ]] || plugins+=(ssh-agent)

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Disable warning about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # we need `lt` for https://github.com/localtunnel/localtunnel

# Load rbenv if installed (to manage your Ruby versions)
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv >/dev/null && eval "$(rbenv init -)"

# Load nvm (to manage your node versions). zprofile already sources nvm.sh for
# login shells (so GUI apps see nvm's node); guard here so interactive shells
# still get it without double-sourcing the (slow) nvm.sh.
export NVM_DIR="$HOME/.nvm"
command -v nvm >/dev/null || { [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; } # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Call `nvm use` automatically in a directory with a `.nvmrc` file
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

# Environment & PATH live in .zprofile so GUI-launched apps (VS Code etc.)
# inherit them — GUI apps read the login environment, not .zshrc. What stays
# below is interactive-only: things that hook into the live shell.

# Store your own aliases in the ~/.aliases file and load them here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# direnv installs a precmd hook into the interactive shell, so it must load
# here (not in .zprofile). Guarded so it's a no-op where direnv isn't installed.
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
