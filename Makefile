install_deps_server:
	-sudo apt update
	-sudo apt install htop vim tmux neovim tig
	-[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	-[ -d ~/.fzf ] && ~/.fzf/install
	-curl -L git.io/antigen > ~/dotfiles/zsh/antigen.zsh
	-[ ! -d ~/.asdf ] && git clone https://github.com/asdf-vm/asdf.git ~/.asdf

install_deps:
	-sudo apt update
	-sudo apt install -y xinit sudo vim net-tools git gnupg make curl zsh tmux tig \
		rxvt-unicode-256color network-manager xfce4-clipman htop gcc autoconf g++ libpq-dev \
		pm-utils
	-[ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	-[ -d ~/.fzf ] && ~/.fzf/install
	-curl -L git.io/antigen > ~/dotfiles/zsh/antigen.zsh
	-[ ! -d ~/.asdf ] && git clone https://github.com/asdf-vm/asdf.git ~/.asdf

		#binutils bison gcc build-essential rxvt-unicode-256color \
		#ttf-mscorefonts-installer fonts-inconsolata \
		#imagemagick libimage-exiftool-perl libreadline6-dev libssl-dev \
		#libxml2-dev libxslt-dev nginx openssl libmysql++-dev mongodb-server \
		#redis-server

symlinks_server:
	-mkdir -p ~/.config
	-ln -snf ~/dotfiles/bashrc ~/.bashrc
	-ln -snf ~/dotfiles/zsh ~/.zsh
	-ln -snf ~/.zsh/zshrc ~/.zshrc
	-ln -snf ~/dotfiles/vim ~/.vim
	-ln -snf ~/.vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/nvim ~/.config/nvim
	-ln -snf ~/dotfiles/tmux ~/.tmux
	-ln -snf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
	-ln -snf ~/dotfiles/gitconfig ~/.gitconfig

symlinks:
	-mkdir -p ~/.config
	-ln -snf ~/dotfiles/profile ~/.profile
	-ln -snf ~/dotfiles/Xsession ~/.Xsession
	-ln -snf ~/dotfiles/zsh ~/.zsh
	-ln -snf ~/.zsh/zshrc ~/.zshrc
	-ln -snf ~/dotfiles/bashrc ~/.bashrc
	-ln -snf ~/dotfiles/tmux ~/.tmux
	-ln -snf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
	-ln -snf ~/dotfiles/vim ~/.vim
	-ln -snf ~/.vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/nvim ~/.config/nvim
	-ln -snf ~/dotfiles/gitconfig ~/.gitconfig
	-ln -snf ~/dotfiles/i3 ~/.config/i3
	-ln -snf ~/dotfiles/Xdefaults ~/.Xdefaults
	-ln -snf ~/dotfiles/setxkbmaprc ~/.setxkbmaprc
	-ln -snf ~/dotfiles/gemrc ~/.gemrc
	#-ln -snf ~/dotfiles/base16-shell ~/.base16-shell
	#-ln -snf ~/dotfiles/irbrc ~/.irbrc
	#-ln -snf ~/dotfiles/awesome ~/.config/awesome
	#-ln -snf ~/dotfiles/nvim ~/.config/nvim

init_subtrees:
	-git subtree add --prefix=base16-xresources https://github.com/base16-templates/base16-xresources master --squash
	-git subtree add --prefix=base16-shell https://github.com/chriskempson/base16-shell master --squash
	-git subtree add --prefix=fonts https://github.com/powerline/fonts master --squash
	-[ -d ~/dotfiles/fonts ] && ~/dotfiles/fonts/install.sh

update_subtrees:
	-git subtree pull --prefix=base16-xresources --squash https://github.com/base16-templates/base16-xresources master
	-git subtree pull --prefix=base16-shell --squash https://github.com/chriskempson/base16-shell master
	-git subtree pull --prefix=fonts --squash https://github.com/powerline/fonts master
	-[ -d ~/dotfiles/fonts ] && ~/dotfiles/fonts/install.sh
