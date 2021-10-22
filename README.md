# Setup

## Install some packages manually (as root)

```bash
sudo apt update
sudo apt install make sudo zsh git
```

## Create a new user (as root)

```bash
adduser klacointe --home /home/klacointe --shell /bin/zsh
usermod -a -G sudo klacointe
```

## Create a new ssh key for created user (as klacointe)

```bash
ssh-keygen -t ed25519
```

## Clone repository

```bash
git clone https://github.com/klacointe/dotfiles
cd dotfiles
```

## Server install

```bash
make install_deps_server
make symlinks_server
```

## Install vim plugins

```bash
vim .
:PlugInstall
```

## Install neovim plugins

```bash
nvim .
:PlugInstall
```
