# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"
source <(fzf --zsh)
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
# preview directory's content with eza when completing cd
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
#zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
#zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
#zstyle ':fzf-tab:*' switch-group '<' '>'
#zstyle ':fzf-tab:*' prefix ''

# Add .zfunc to fpath for zsh functions autoloading
fpath+=(~/.zfunc $fpath)
autoload -Uz ee

function glowgpt() {
  local prompt="Answer in no more than 5 lines of text (not including possible code block) : $1"
  echo "Prompt: $prompt"
  command chatgpt $prompt | glow
}

###
### Default editor
###
export EDITOR=code

###
### FZF
###
#export FZF_PATH=/opt/homebrew/opt/fzf
#source <(fzf --zsh)
#xport FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
#export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
#export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#alias fzp="fzf --preview='less {}' --preview-window=right:80% --layout reverse --border top"

### Utils
###
###

# Tools
#eval "$(thefuck --alias)"
#eval "$(zoxide init zsh)"
eval "$(thefuck --alias)"

###
### EZA
###
export EZA_CONFIG_DIR="/Users/benjaminbini/.config/eza"

###
### OMZ
###
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode reminder

# iterm2
zstyle :omz:plugins:iterm2 shell-integration yes
zstyle ':omz:update' mode reminder

## Load aliases
[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases

#plugins=(git )
#plugins=(git zsh-syntax-highlighting fast-syntax-highlighting aliases alias-finder  zsh-autocomplete fzf-tab)
plugins=(git zsh-syntax-highlighting fast-syntax-highlighting aliases alias-finder )
source $ZSH/oh-my-zsh.sh

source ~/.config/zsh/aichat


## Alias finder
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

###
### PowerLevel10k
###
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add Kit to PATH
export PATH="$PATH:/Users/benjaminbini/.kit/bin"

# Ruby

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
eval "$(gh copilot alias -- zsh)"

export DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
eval "$(gh copilot alias -- zsh)"

# bun completions
[ -s "/Users/benjaminbini/.bun/_bun" ] && source "/Users/benjaminbini/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Make cursor work
if [[ "$TERM_PROGRAM" == "vscode" || "$TERM_PROGRAM" == "Cursor" ]]; then
  export VSCODE_SHELL_INTEGRATION=0
  return
fi

export PATH="$HOME/.cargo/bin:$PATH"

export PATH=$PATH:/Users/benjaminbini/.spicetify

# Make add_zsh_alias.sh available as a function and in PATH
export PATH="$HOME/.config/zsh:$PATH"
add_zsh_alias() {
  "$HOME/.config/zsh/add_zsh_alias.sh" "$@"
}
