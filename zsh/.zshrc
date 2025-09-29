# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# .zshrc - Zsh configuration file

## Load aliases
source $ZDOTDIR/.zsh_aliases

# Set ZSH options
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.

# Plugin manager
source /opt/homebrew/share/antigen/antigen.zsh

## Autocompletion settings
# Load completion settings first (includes compinit)
source $ZDOTDIR/completion.sh

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

# Load thefuck
eval $(thefuck --alias)

# Define custom word separators characters for better navigation
export WORDCHARS='*_-.[]~;!$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal


antigen apply

# # Load P10K theme
# source $XDG_CONFIG_HOME/powerlevel10k/powerlevel10k.zsh-theme

# # To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Swiftly completion will be loaded from fpath

 
eval "$(starship init zsh)"
# bun completions
[ -s "/Users/benjaminbini/.bun/_bun" ] && source "/Users/benjaminbini/.bun/_bun"

# Added by swiftly
. "$HOME/.config/swiftly/env.sh"

. "$HOME/.config/local/share/../bin/env"
