# Brewfile — full machine setup (Le Wagon toolset + terminal/multi-agent stack)
# Install everything with:  brew bundle --file=Brewfile
# (install.sh runs this automatically on macOS)

# === Terminal emulator ===
cask "ghostty"                          # fast, native, GPU-accelerated terminal

# === Nerd Font (Ghostty + powerline/devicons in prompts) ===
cask "font-jetbrains-mono-nerd-font"

# === Multi-agent multiplexer ===
brew "herdr"                            # agent-aware terminal multiplexer (Claude Code, Copilot, ...)

# === Core CLI utilities (Le Wagon defaults) ===
brew "git"
brew "gh"                               # GitHub CLI — also handles git auth (gh auth login)
brew "wget"
brew "imagemagick"
brew "jq"
brew "openssl@3"

# === Version managers ===
# Node/TS is the focus — managed via nvm (installed by the Le Wagon flow's curl
# script, loaded in ~/.zshrc), so it is intentionally NOT a brew formula here.
brew "rbenv"                            # Ruby version manager only — no Ruby version installed yet

# === Database ===
brew "postgresql@18"                    # latest stable major (Postgres has no formal LTS)

# === Editor ===
cask "visual-studio-code"

# NOTE: Slack is installed manually via its GUI installer (intentionally not a cask here).
