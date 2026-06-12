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
4. Symlinks the dotfiles, VS Code settings/keybindings, and the Ghostty config; adds the SSH key to the keychain. The SSH config is only symlinked if you don't already have a `~/.ssh/config` (an existing one is left untouched, not replaced).
5. Installs the curated VS Code extensions and seeds a default `~/.config/herdr/config.toml`.

Environment/PATH lives in `.zprofile` (so GUI apps like VS Code inherit it); interactive-only setup (prompt, aliases, plugins, direnv, sdkman) lives in `.zshrc`.

## WSL / Ubuntu install

The same `install.sh` is self-contained on Debian/Ubuntu (including WSL), driven by the `Aptfile` instead of the `Brewfile`. Because the script runs under zsh, install zsh first:

```bash
sudo apt update && sudo apt install -y zsh
zsh install.sh
```

It then apt-installs the toolchain (git, gh, postgres, and pyenv's build dependencies), installs oh-my-zsh + plugins, and installs the version managers (`nvm`, `pyenv`, and `rbenv` via git since there's no Homebrew). The macOS-only bits — Ghostty, herdr, and the SSH/keychain config — are skipped on WSL. VS Code runs from the Windows host via the Remote-WSL extension (which provides the `code` shim), so it isn't in the `Aptfile`.

### Terminal (WezTerm)

Ghostty has no Windows build, so on Windows the terminal is [WezTerm](https://wezterm.org/) — GPU-accelerated, with native splits and a config (`wezterm/wezterm.lua`) that mirrors the Ghostty setup (JetBrains Mono Nerd Font, Catppuccin auto light/dark, the same split keybinds under `CTRL+SHIFT`).

Install it **on Windows** (not inside WSL) and add the font:

```powershell
winget install wez.wezterm
winget install --id DEVCOM.JetBrainsMonoNerdFont   # or download from nerdfonts.com
```

`install.sh` copies `wezterm/wezterm.lua` to `C:\Users\<you>\.wezterm.lua` (a copy, not a symlink — Windows apps don't follow WSL symlinks). To update it later, edit the repo copy and delete the Windows one, then re-run. The config launches straight into the `WSL:Ubuntu` domain — change that line if your distro is named differently (`wsl -l`).
