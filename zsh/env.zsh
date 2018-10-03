path=(
       /bin
       /sbin
       /usr/bin
       /usr/sbin
       /usr/bin/X11
       /usr/X11R6/bin
       /usr/local/bin
       /usr/local/sbin
       /usr/games
       $HOME/bin
       $HOME/local/bin
       $HOME/.local/bin
       .
)

#### Fix TERM for base16 colors
#export TERM=rxvt-unicode-256color

#### Viewer/Editeur par defaut (pour Crontab, CVS,...)
export VISUAL=vim
export EDITOR=vim

### Yan global bins
PATH=$PATH:~/.yarn/bin

### Phantomjs
PATH=$PATH:~/opt/phantomjs-1.7.0-linux-x86_64/bin

### Vagrant
PATH=$PATH:/opt/vagrant/bin

### Rbenv
[[ -d "$HOME/.rbenv" ]] && \
  PATH=$PATH:~/.rbenv/bin && \
  eval "$(rbenv init -)"

### nvm
[[ -s "$HOME/.nvm/nvm.sh" ]] && . "$HOME/.nvm/nvm.sh"
PATH=$PATH:./node_modules/.bin

# Elixir (kiex)
test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"
export ERL_AFLAGS="-kernel shell_history enabled"

# Golang
#
# GVM
#[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
#
# Manual
export GOROOT=$HOME/.go/go1.9
export GOPATH=$HOME/.go/workspace
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# io.js
#PATH=$PATH:~/src/iojs/bin

# The next line updates PATH for the Google Cloud SDK.
#source '/home/klacointe/google-cloud-sdk/path.zsh.inc'

# The next line enables shell command completion for gcloud.
#source '/home/klacointe/google-cloud-sdk/completion.zsh.inc'

# nwjs
PATH=$PATH:~/src/nwjs

# Pyenv
[[ -s "$HOME/.pyenv" ]] && \
	PYENV_ROOT="$HOME/.pyenv" && \
	PATH="$PYENV_ROOT/bin:$PATH" && \
	eval "$(pyenv init -)"

#### Permissions rw-r--r-- pour les fichiers crées
#### et rwxr-xr-x pour les répertoires crées
umask 022

# Google cloud storage
PATH=$PATH:~/gsutil

# Android SDK
PATH=$PATH:~/android-sdk-linux/tools:~/android-sdk-linux/platform-tools

# Bento
PATH=$PATH:~/src/Bento4-SDK-1-4-3-597.x86_64-unknown-linux/bin

# Rust / Cargo
PATH=$PATH:~/.cargo/bin

# Oracle instant client
#export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1:$LD_LIBRARY_PATH
#export PATH=/opt/oracle/instantclient_12_1:$PATH

# Crenv (crystal)
#export PATH="$HOME/.crenv/bin:$PATH"
#eval "$(crenv init -)"

# awless
PATH=$PATH:~/.awless

# alacritty
fpath+=~/.zsh/.zsh_functions
