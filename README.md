# Bootstrap

## Install HomeBrew, YADM and 1Password

```shell
./setup.sh
```

## Configure 1Password

When 1Password is installed (with setup.sh):
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

## Configure Yabai

Yabai will be started automatically.
Think about disabling SIP

```
git clone https://github.com/AdamWagner/stackline.git ~/.hammerspoon/stackline
```

In Hammerspoon console:
```
hs.ipc.cliInstall()
```
Confirm
```
which hs
```
