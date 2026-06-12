This repository is used by [Le Wagon](https://www.lewagon.com) students.

## Toolset

- [oh-my-zsh](http://ohmyz.sh/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/)

## macOS terminal & multi-agent stack

Installed automatically by `install.sh` on macOS (via [Homebrew](https://brew.sh/) + `Brewfile`):

- [Ghostty](https://ghostty.org/) — fast, native, GPU-accelerated terminal. Config: `ghostty/config` → `~/.config/ghostty/config`.
- [herdr](https://herdr.dev/) — agent-aware terminal multiplexer for running and tracking multiple AI agents (Claude Code, Copilot, …). Run with `herdr` or the `agents` alias.
- JetBrainsMono Nerd Font — used by Ghostty.

The `Brewfile` also covers the core Le Wagon toolset (git, gh, wget, imagemagick, jq, openssl), `rbenv` (Ruby manager only — no Ruby version installed), `postgresql@18`, and VS Code. Slack is installed manually via its GUI.

## Fresh-Mac install

Run `zsh install.sh`. On macOS it is self-contained and idempotent — re-running it only fills in what's missing:

1. Bootstraps Homebrew (if missing) and runs `brew bundle`.
2. Installs `oh-my-zsh`, then its external plugins (autosuggestions, syntax-highlighting).
3. Installs the version managers it doesn't get from Homebrew: `nvm` → `~/.nvm` (node/TS, the focus) and `pyenv` → `~/.pyenv`. `rbenv` comes from the Brewfile.
4. Symlinks the dotfiles, VS Code settings/keybindings, the Ghostty config, and the SSH config; adds the SSH key to the keychain.
5. Installs the curated VS Code extensions and seeds a default `~/.config/herdr/config.toml`.

Environment/PATH lives in `.zprofile` (so GUI apps like VS Code inherit it); interactive-only setup (prompt, aliases, plugins, direnv, sdkman) lives in `.zshrc`.
