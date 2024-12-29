# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
setopt menu_complete
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate _prefix

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"


###
### Brew
####
export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"

###
### OMZ
###
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

#plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
plugins=(git)
source $ZSH/oh-my-zsh.sh

###
### Utils
###

# Tools 
eval "$(thefuck --alias)"
eval "$(zoxide init zsh)"

# Load aliases
[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases

eval $(thefuck --alias)

###
### PowerLevel10k
###
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT) 
export PATH="/Users/benjaminbini/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
