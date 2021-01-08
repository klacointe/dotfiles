# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

source ~/.Xsession
ssh-add ~/.ssh/id_dsa > /dev/null

## Usefull for xdg-open
export BROWSER=google-chrome-stable
#xdg-mime default chromium.desktop x-scheme-handler/http
#xdg-mime default chromium.desktop x-scheme-handler/https

#export PEPPER_FLASH_VERSION=$(grep '"version":' /opt/google/chrome-unstable/PepperFlash/manifest.json| grep -Po '(?<=version": ")(?:\d|\.)*')
## Pass this flasg to chromium in /etc/chromium.d/default-flags :
export CHROMIUM_FLAGS="--password-store=detect --ppapi-flash-path=/home/klacointe/.config/google-chrome/PepperFlash/23.0.0.207/libpepflashplayer.so --ppapi-flash-version=$PEPPER_FLASH_VERSION"
