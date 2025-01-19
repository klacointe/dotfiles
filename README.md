# Setup

```
sudo lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.1 LTS
Release:	24.04
Codename:	noble
```


## Install packages

```
sudo apt install make gcc git curl
```

Optional:
```
sudo apt install htop gnome-tweaks parcellite pulseaudio-utils
```

## Parcellite (optional)

Enable these options:

- Use Primary (Selection)
- Synchronize clipboards


## Fonts

```
ln -s /home/klacointe/dotfiles/fonts /home/klacointe/.fonts
fc-cache -fv
```

Links:
- https://www.nerdfonts.com/font-downloads


## Git

```
ln -s /home/klacointe/dotfiles/gitconfig /home/klacointe/.gitconfig
```


## Retrieve config files

```
git clone git@github.com:klacointe/dotfiles
```


## X

```
ln -s /home/klacointe/dotfiles/Xsession  /home/klacointe/.Xsession
ln -s /home/klacointe/dotfiles/Xdefaults  /home/klacointe/.Xdefaults
ln -s /home/klacointe/dotfiles/setxkbmaprc /home/klacointe/.setxkbmaprc
```


## Terminal & Shell

```
sudo apt install zsh tmux

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

sudo ln -s /home/klacointe/.local/kitty.app/bin/kitty /usr/bin/
sudo ln -s /home/klacointe/.local/kitty.app/bin/kitten /usr/bin/

ln -s /home/klacointe/dotfiles/kitty /home/klacointe/.config/kitty

ln -s /home/klacointe/dotfiles/zsh/zshrc /home/klacointe/.zshrc
ln -s /home/klacointe/dotfiles/zsh /home/klacointe/.zsh

ln -s /home/klacointe/dotfiles/tmux/tmux.conf /home/klacointe/.tmux.conf

sudo usermod -s /bin/zsh klacointe
```


## Neovim

You'll need Neovim >= 0.10

```
sudo apt install fzf luarocks ripgrep fd-find
```

```
sudo snap install nvim --classic
ln -s /home/klacointe/.config/nvim /home/klacointe/dotfiles/nvim
```


## Languages

```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf

asdf plugin add elixir
asdf plugin add nodejs
asdf plugin add ruby

asdf install elixir latest
asdf install nodejs latest
asdf install ruby latest
```


## Window Manager

### i3

```
sudo apt install i3 flameshot blueman
ln -s /home/klacointe/dotfiles/i3 /home/klacointe/.config/i3
```

## Social

```
sudo snap install telegram-desktop
sudo snap install discord
sudo snap install slack
```
