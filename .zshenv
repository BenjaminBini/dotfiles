export PATH="$XDG_BIN_HOME:$PATH"
export PATH="$HOME/.cargo/bin:$HOME/.bun/bin:$HOME/.rd/bin:$PATH"
export PATH="$HOME/.nvm/versions/node/v23.9.0/bin::$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:/System/Cryptexes/App/usr/bin:$PATH"
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:$PATH"
export PATH="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/Applications/Little Snitch.app/Contents/Components:$PATH"
export PATH="/Applications/VMware Fusion.app/Contents/Public:/Applications/iTerm.app/Contents/Resources/utilities:/Users/benjaminbini/Library/Application Support/JetBrains/Toolbox/scripts:$PATH"
export PATH="/opt/homebrew/opt/fzf/bin:$HOME/.kit/bin:$HOME/.spicetify:$PATH"

export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/Library/Caches"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="$TMPDIR/runtime-$UID"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="/tmp"

# Define paths for common programs not using XDG
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history";
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/config"


export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/.claude"

export EDITOR="code"
export VISUAL="code"

export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

export SWIFTLY_HOME_DIR="$XDG_CONFIG_HOME/swiftly"
export SWIFTLY_BIN_DIR="$XDG_BIN_HOME/bin"