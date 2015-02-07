# Setup

```bash
git clone https://github.com/klacointe/dotfiles
```

# Deb

```bash
aptitude install make git zsh tmux \
  ttf-mscorefonts-installer fonts-inconsolata
```

# Plugins and symlinks:

```bash
make symlinks
make install
make update
```

```bash
ln -s dotfiles/profile .profile
ln -s dotfiles/zsh .zsh
ln -s .zsh/zshrc .zshrc
```

## Vim

```bash
ln -s dotfiles/vim .vim
ln -s .vim/vimrc .vimrc
:PlugInstall
```

## Fonts

```bash
https://github.com/powerline/fonts
```

## Git

```bash
ln -s dotfiles/gitconfig .gitconfig
```

## Ruby

```bash
ln -s dotfiles/gemrc .gemrc
```

## Go

```bash
go get github.com/mattn/gom
go get github.com/bradfitz/goimports
```

## X

```bash
cd dotfiles
git remote add -f base16-xresources https://github.com/chriskempson/base16-xresources
git subtree add --prefix base16-xresources base16-xresources master --squash
cd
ln -s dotfiles/Xdefaults .Xdefaults
ln -s dotfiles/Xsession .Xsession
```

## Zsh

```bash
cd dotfiles
git remote add -f base16-shell https://github.com/chriskempson/base16-shell
git subtree add --prefix base16-shell base16-shell master --squash
cd
ln -s dotfiles/base16-shell base16-shell 
```

## Bash

```bash
ln -s dotfiles/bashrc .bashrc
```

## Awesome

```bash
ln -s dotfiles/awesome .config/awesome
```

## Tmux

```bash
ln -s dotfiles/tmux .tmux
ln -s dotfiles/tmux/tmux.conf .tmux.conf
```

```bash
git remote add -f tmux-copycat https://github.com/tmux-plugins/tmux-copycat
git subtree add --prefix .tmux/plugins/tmux-copycat tmux-copycat master --squash
```

```bash
git remote add -f tpm https://github.com/tmux-plugins/tpm
git subtree add --prefix .tmux/plugins/tpm tpm master --squash
```

## Update substree:

```bash
git fetch tmux-copycat master
git subtree pull --prefix .tmux/plugins/tmux-copycat tmux-copycat master --squash
```

