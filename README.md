# Bootstrap

## Install HomeBrew, YADM and 1Password

Install HomeBrew.

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Install yadm and 1Password.

```shell
brew install yadm
brew install --cask 1password
```

## Configure 1Password

When 1Password is installed (with setup.sh):
* Launch 1Password app
* Login
* In the developer section:
    * Enable SSH Agent
    * Enable CLI integration
* Add the necessary SSH Keys if they are not already uploaded

## Install dotfiles

```shell
yadm clone git@github.com:BenjaminBini/dotfiles.git
```

After cloning, the bootstrap script is automatically launched.

Let it run, enter your sudo password when/if necesssary.

To ensure correct display of icons and fonts in iTerm, start iTerm2 after bootstrap scripts finishes. Go to the Profile tab. For all profiles, go to the Text tab and at the bottom click on "Manage Special Exceptions...".
In the dialog, select all items of the list and click on the minus icon to remove them. When they are deleted, click on "Install Nerd Front Bundle".

You should be good.
