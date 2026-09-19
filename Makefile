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
		rxvt-unicode-256color network-manager xfce4-clipman htop gcc autoconf g++ libpq-dev python3-venv \
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
	#-ln -snf ~/dotfiles/vim ~/.vim
	-ln -snf ~/dotfiles/nvim ~/.config/nvim
	-mkdir -p ~/.vim
	-ln -snf ~/dotfiles/nvim/autoload ~/.vim/autoload
	-ln -snf ~/dotfiles/vim/vimrc ~/.vimrc
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
	#-ln -snf ~/dotfiles/vim ~/.vim
	#-ln -snf ~/.vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/nvim ~/.config/nvim
	-mkdir -p ~/.vim
	#-ln -snf ~/dotfiles/nvim/autoload ~/.vim/autoload
	-ln -snf ~/dotfiles/vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/gitconfig ~/.gitconfig
	-ln -snf ~/dotfiles/i3 ~/.config/i3
	-ln -snf ~/dotfiles/i3status ~/.config/i3status
	-ln -snf ~/dotfiles/Xdefaults ~/.Xdefaults
	-ln -snf ~/dotfiles/setxkbmaprc ~/.setxkbmaprc
	-ln -snf ~/dotfiles/gemrc ~/.gemrc
	#-ln -snf ~/dotfiles/base16-shell ~/.base16-shell
	#-ln -snf ~/dotfiles/irbrc ~/.irbrc
	#-ln -snf ~/dotfiles/awesome ~/.config/awesome
	-base16_porple

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

install_iptvnator:
	-~/dotfiles/bin/install_iptvnator

# --- Credential leak protection --------------------------------------------

GITLEAKS_VERSION := 8.30.1

install_gitleaks:
	curl -sSfL -o /tmp/gitleaks.tar.gz "https://github.com/gitleaks/gitleaks/releases/download/v$(GITLEAKS_VERSION)/gitleaks_$(GITLEAKS_VERSION)_linux_x64.tar.gz"
	tar -xzf /tmp/gitleaks.tar.gz -C /tmp gitleaks
	mkdir -p ~/bin && install -m 755 /tmp/gitleaks ~/bin/gitleaks
	~/bin/gitleaks version

# core.hooksPath is local config, not versioned: re-run this on every machine
# and after every fresh clone.
install_hooks:
	git -C ~/dotfiles config core.hooksPath githooks
	@echo "hooks enabled: $$(git -C ~/dotfiles config core.hooksPath)"

secrets_setup: install_gitleaks install_hooks

# Scan the working tree (including untracked files).
scan:
	gitleaks dir --no-banner -v .

# Scan the whole history.
scan_history:
	gitleaks git --no-banner -v .

.PHONY: install_gitleaks install_hooks secrets_setup scan scan_history
