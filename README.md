# Bootstrap

## Install HomeBrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

```

## Install YADM

```shell
brew install yadm
```

## Install and configure 1Password


```shell
brew install --cask 1password
```

When 1Password is installed:
* Launch 1Password app
* Login
* In the developer section:
    * Enable SSH Agent
    * Enable CLI integration
* Add the necessary SSH Keys if they are not already uploaded
* Go back to your terminal

## Configure terminal

```shell
yadm clone git@github.com:BenjaminBini/dotfiles.git
```

After cloning, the bootstrap script is automatically launched.

Let it run, enter your sudo password when/if necesssary.

When it finished, start iTerm2 and go to the Profile section. For all profiles, go to the Text taba and at the bottom click "Manage Special Exceptions...".
In the dialog, select all items of the list and click on the minus icon to remove them. When they are deleted, click on "Install Nerd Front Bundle".

## Configure Aeorospace

Start Aerospace.app.

