#!/bin/zsh

###
### Install brew deps
###
unset HOMEBREW_BUNDLE_FILE
brew bundle install --quiet  --global
