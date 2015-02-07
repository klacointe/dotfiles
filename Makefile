symlinks:
	-ln -s ~/dotfiles/profile ~/.profile
	-ln -s ~/dotfiles/zsh ~/.zsh 
	-ln -s ~/.zsh/zshrc ~/.zshrc
	-ln -s ~/dotfiles/vim ~/.vim
	-ln -s ~/.vim/vimrc ~/.vimrc
	-ln -s ~/dotfiles/gitconfig ~/.gitconfig
	-ln -s ~/dotfiles/gemrc ~/.gemrc 
	-ln -s ~/dotfiles/bashrc ~/.bashrc
	-mkdir -p ~/.config
	-ln -s ~/dotfiles/awesome ~/.config/awesome
	-ln -s ~/dotfiles/tmux ~/.tmux
	-ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
	-ln -s ~/dotfiles/Xdefaults ~/.Xdefaults
	-ln -s ~/dotfiles/Xsession ~/.Xsession
	-ln -s ~/dotfiles/base16-shell ~/.base16-shell

install:
	-git remote add -f base16-xresources "https://github.com/chriskempson/base16-xresources"
	-git subtree add --prefix base16-xresources base16-xresources master --squash
	-git remote add -f base16-shell "https://github.com/chriskempson/base16-shell"
	-git subtree add --prefix base16-shell base16-shell master --squash
	-git remote add -f tmux-copycat "https://github.com/tmux-plugins/tmux-copycat"
	-git subtree add --prefix .tmux/plugins/tmux-copycat tmux-copycat master --squash
	-git remote add -f tpm "https://github.com/tmux-plugins/tpm"
	-git subtree add --prefix .tmux/plugins/tpm tpm master --squash
	-git remote add -f powerline-fonts "https://github.com/powerline/fonts"
	-git subtree add --prefix fonts powerline-fonts master --squash && cd fonts && ./install.sh

update:
	-git fetch base16-xresources master
	-git fetch base16-shell master
	-git fetch tmux-copycat master
	-git fetch tpm master
	-git fetch powerline-fonts master && cd fonts && ./install.sh
