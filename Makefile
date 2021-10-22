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
	-git subtree add --prefix=base16-xresources https://github.com/base16-templates/base16-xresources master --squash
	-git subtree add --prefix=base16-shell https://github.com/chriskempson/base16-shell master --squash
	-git subtree add --prefix=fonts https://github.com/powerline/fonts master --squash

update_subtrees:
	-git fetch base16-xresources master
	-git fetch base16-shell master
	-git fetch powerline-fonts master && cd fonts && ./install.sh
