install: install_debs symlinks init_subtrees install_rbenv install_nvm install_gvm

install_debs:
	-sudo aptitude install -y sudo make curl git zsh tmux tig mercurial binutils bison gcc build-essential ttf-mscorefonts-installer fonts-inconsolata ncmpcpp

symlinks:
	-ln -snf ~/dotfiles/profile ~/.profile
	-ln -snf ~/dotfiles/zsh ~/.zsh 
	-ln -snf ~/.zsh/zshrc ~/.zshrc
	-ln -snf ~/dotfiles/vim ~/.vim
	-ln -snf ~/.vim/vimrc ~/.vimrc
	-ln -snf ~/dotfiles/gitconfig ~/.gitconfig
	-ln -snf ~/dotfiles/gemrc ~/.gemrc 
	-ln -snf ~/dotfiles/bashrc ~/.bashrc
	-mkdir -p ~/.config
	-ln -snf ~/dotfiles/awesome ~/.config/awesome
	-ln -snf ~/dotfiles/tmux ~/.tmux
	-ln -snf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
	-ln -snf ~/dotfiles/Xdefaults ~/.Xdefaults
	-ln -snf ~/dotfiles/Xsession ~/.Xsession
	-ln -snf ~/dotfiles/base16-shell ~/.base16-shell
	-ln -snf ~/dotfiles/ncmpcpp ~/.ncmpcpp

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
	-git subtree add --prefix fonts powerline-fonts master --squash && cd fonts && ./install.sh

update_subtrees:
	-git fetch base16-xresources master
	-git fetch base16-shell master
	-git fetch tmux-copycat master
	-git fetch tpm master
	-git fetch powerline-fonts master && cd fonts && ./install.sh

install_rbenv:
	-if [ ! -d ~/.rbenv ]; then git clone https://github.com/sstephenson/rbenv ~/.rbenv; fi
	-if [ ! -d ~/.rbenv/plugins/ruby-build ]; then git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build; fi
	-if [ ! -d ~/.rbenv/plugins/rbenv-gem-rehash ]; then git clone https://github.com/sstephenson/rbenv-gem-rehash ~/.rbenv/plugins/rbenv-gem-rehash; fi

install_nvm:
	-if [ ! -d ~/.nvm ]; then git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`; fi

install_gvm:
	-if [ ! -d ~/.gvm ]; then bin/install_gvm; fi

# Only needed for outdated git versions
install_git_subtree:
	-if [ ! -d git/sources ]; then git clone https://github.com/git/git git/sources; fi
	-cd git/sources/contrib/subtree && make && sudo install -m 755 git-subtree /usr/lib/git-core
