install: install_debs init_subtrees symlinks

install_debs:
	-sudo apt-get update
	-sudo apt-get install -y xinit sudo vim net-tools git gnupg make curl zsh tmux tig \
		rxvt-unicode-256color network-manager xfce4-clipman htop gcc autoconf g++ libpq-dev \
		pm-utils

		#binutils bison gcc build-essential rxvt-unicode-256color \
		#ttf-mscorefonts-installer fonts-inconsolata ncmpcpp hexchat \
		#imagemagick libimage-exiftool-perl libreadline6-dev libssl-dev \
		#libxml2-dev libxslt-dev nginx openssl libmysql++-dev mongodb-server \
		#redis-server

# TODO add .fzf

symlinks:
	-ln -snf ~/dotfiles/profile ~/.profile
	-ln -snf ~/dotfiles/zsh ~/.zsh
	-ln -snf ~/.zsh/zshrc ~/.zshrc
	-ln -snf ~/dotfiles/vim ~/.vim
	-ln -snf ~/dotfiles/nvim ~/.config/nvim
	-ln -snf ~/.vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/gitconfig ~/.gitconfig
	#-ln -snf ~/dotfiles/irbrc ~/.irbrc
	-ln -snf ~/dotfiles/gemrc ~/.gemrc
	-ln -snf ~/dotfiles/bashrc ~/.bashrc
	-mkdir -p ~/.config
	#-ln -snf ~/dotfiles/awesome ~/.config/awesome
	-ln -snf ~/dotfiles/i3 ~/.config/i3
	-ln -snf ~/dotfiles/tmux ~/.tmux
	-ln -snf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
	-ln -snf ~/dotfiles/Xdefaults ~/.Xdefaults
	-ln -snf ~/dotfiles/setxkbmaprc ~/.setxkbmaprc
	-ln -snf ~/dotfiles/Xsession ~/.Xsession
	-ln -snf ~/dotfiles/base16-shell ~/.base16-shell
	#-ln -snf ~/dotfiles/ncmpcpp ~/.ncmpcpp
	#-ln -snf ~/dotfiles/alacritty ~/.config/alacritty
	#-ln -snf ~/dotfiles/nvim ~/.config/nvim

init_subtrees:
	-git remote show base16-xresources || git remote add -f base16-xresources "https://github.com/chriskempson/base16-xresources"
	-git subtree add --prefix base16-xresources base16-xresources master --squash
	-git remote show base16-shell || git remote add -f base16-shell "https://github.com/chriskempson/base16-shell"
	-git subtree add --prefix base16-shell base16-shell master --squash
	-git remote show tmux-copycat || git remote add -f tmux-copycat "https://github.com/tmux-plugins/tmux-copycat"
	-git subtree add --prefix tmux/plugins/tmux-copycat tmux-copycat master --squash
	-git remote show tpm || git remote add -f tpm "https://github.com/tmux-plugins/tpm"
	-git subtree add --prefix tmux/plugins/tpm tpm master --squash
	-git remote show powerline-fonts || git remote add -f powerline-fonts "https://github.com/powerline/fonts"
	-git subtree add --prefix fonts powerline-fonts master --squash
	-cd fonts && ./install.sh

update_subtrees:
	-git fetch base16-xresources master
	-git fetch base16-shell master
	-git fetch tmux-copycat master
	-git fetch tpm master
	-git fetch powerline-fonts master && cd fonts && ./install.sh
