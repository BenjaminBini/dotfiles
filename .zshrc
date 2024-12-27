# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"

###
### OMZ
###
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)

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

