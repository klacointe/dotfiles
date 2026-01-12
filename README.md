# Setup

```sh
sudo lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description: Ubuntu 24.04.1 LTS
Release: 24.04
Codename: noble
```

## Install packages

```sh
sudo apt install make gcc g++ git curl
```

Optional:

```sh
sudo apt install htop gnome-tweaks parcellite pulseaudio-utils inotify-tools tig
```

## Parcellite (optional)

Enable these options:

- Use Primary (Selection)
- Synchronize clipboards

## Fonts

```sh
ln -s /home/klacointe/dotfiles/fonts /home/klacointe/.fonts
fc-cache -fv
```

Links:

- <https://www.nerdfonts.com/font-downloads>

## Git

```sh
ln -s /home/klacointe/dotfiles/gitconfig /home/klacointe/.gitconfig
```

## Retrieve config files

```sh
git clone git@github.com:klacointe/dotfiles
```

## X

```sh
ln -s /home/klacointe/dotfiles/Xsession  /home/klacointe/.Xsession
ln -s /home/klacointe/dotfiles/Xdefaults  /home/klacointe/.Xdefaults
ln -s /home/klacointe/dotfiles/setxkbmaprc /home/klacointe/.setxkbmaprc
```

## Terminal & Shell

```sh
sudo apt install zsh tmux

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

sudo ln -s /home/klacointe/.local/kitty.app/bin/kitty /usr/bin/
sudo ln -s /home/klacointe/.local/kitty.app/bin/kitten /usr/bin/

ln -s /home/klacointe/dotfiles/kitty /home/klacointe/.config/kitty

ln -s /home/klacointe/dotfiles/zsh/zshrc /home/klacointe/.zshrc
ln -s /home/klacointe/dotfiles/zsh /home/klacointe/.zsh

ln -s /home/klacointe/dotfiles/tmux/tmux.conf /home/klacointe/.tmux.conf

sudo usermod -s /bin/zsh klacointe

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## Languages

Download asdf bin from https://github.com/asdf-vm/asdf/releases

Add this to ~/.zsh/zshrc

```sh
export PATH="${ASDF_DATA_DIR:-HOME/.asdf}/shims:$PATH"
```

```sh
asdf plugin add erlang
asdf install erlang latest
asdf global erlang latest

asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest

asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

sudo apt install zlib1g libffi-dev libyaml-dev libpq-dev
asdf plugin add ruby
asdf install ruby latest
asdf global ruby latest
```

## Neovim

You'll need Neovim >= 0.10

```sh
sudo apt install fzf luarocks ripgrep fd-find
npm install markdownlint-cli2 --global
```

```sh
sudo snap install nvim --classic
ln -s /home/klacointe/.config/nvim /home/klacointe/dotfiles/nvim
```

## Window Manager

### i3

```sh
sudo apt install i3 flameshot blueman pavucontrol xcalib
ln -s /home/klacointe/dotfiles/i3 /home/klacointe/.config/i3
```

## Social

```sh
sudo snap install telegram-desktop
sudo snap install discord
sudo snap install slack
```

## Nginx

```sh
sudo apt install nginx-extras
```

## Databases

### Postgres

```sh
sudo apt install postgresql
```

```sh
sudo su postgres
psql
postgres=# ALTER USER postgres with encrypted password 'my-password';
```

```sh
sudo nvim /etc/postgresql/16/main/pg_hba.conf

local   all             postgres                                trust
```

```sh
sudo systemctl restart postgres
psql -U postres
```

### Redis

```sh
sudo apt install redis
redis-cli
```

## Games

### Steam

```sh
sudo snap install steam
```

### Steam Link :x:

```sh
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.valvesoftware.SteamLink
flatpak run com.valvesoftware.SteamLink
```

```
cat /usr/local/bin/steamlink
#!/bin/sh

flatpak run com.valvesoftware.SteamLink
```

### yuki-iptv

```sh
sudo apt install flatpak
flatpak install flathub yuki-iptv
flatpak run io.github.yuki_iptv.yuki-iptv
```

```
cat /usr/local/bin/yuki-iptv
#!/bin/sh

flatpak run io.github.yuki_iptv.yuki-iptv
```
