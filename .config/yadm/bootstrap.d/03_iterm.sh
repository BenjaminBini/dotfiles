###
### iTerm conf
###
echo "Setting up iTerm2"
defaults write com.googlecode.iterm2 PrefsCustomFolder "$HOME/.iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true


###
### PowerLevel10k
###
echo "Install PowerLevel10k"
if [ ! -d  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git 
fi





