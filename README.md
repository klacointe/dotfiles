# Setup

## Install some packages manually (as root)

```bash
sudo apt update
sudo apt install make sudo zsh git curl
```

## Create a new user (as root)

```bash
adduser klacointe --home /home/klacointe --shell /bin/zsh
usermod -a -G sudo klacointe
```

## Create a new ssh key for created user

```bash
ssh-keygen -t ed25519
```

## Clone repository

```bash
git clone https://github.com/klacointe/dotfiles
cd dotfiles
```

# Install

## Server

```bash
make install_deps_server
make symlinks_server
```

## Laptop

```bash
make install_deps
make symlinks
make init_subtrees
```

# Editor

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
