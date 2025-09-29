# Bootstrap

## Install HomeBrew and 1Password

Install HomeBrew.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install --cask 1password
```

## Configure 1Password

When 1Password is installed (with setup.sh):

- Launch 1Password app
- Login
- In the developer section:
  - Enable SSH Agent
  - Enable CLI integration
- Add the necessary SSH Keys if they are not already uploaded

## Install dotfiles

```shell
./install
```
