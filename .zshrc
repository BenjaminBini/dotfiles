# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
setopt menu_complete
#zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate _prefix
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/opt/python/libexec/bin:$PATH"

###
### Default editor
###
export EDITOR=micro

###
### Brew
####
export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"

###
### FZF
###
export FZF_PATH=/opt/homebrew/opt/fzf
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height ~40% --layout reverse --border top'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
alias pf-="fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down --height ~60% --layout reverse --border top"


###
### Utils
###

# Tools 
eval "$(thefuck --alias)"
eval "$(zoxide init zsh)"
eval $(thefuck --alias)


###
### OMZ
###
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="powerlevel10k/powerlevel10k"

#plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
plugins=(git fzf-zsh-plugin fzf-tab)
source $ZSH/oh-my-zsh.sh

## Load aliases
[ -f $HOME/.zsh_aliases ] && source $HOME/.zsh_aliases


###
### PowerLevel10k
###
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT) 
export PATH="/Users/benjaminbini/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
