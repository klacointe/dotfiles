alias ls='ls --classify --tabsize=0 --literal --color=auto --show-control-chars --human-readable'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lsg='ls | grep $1'

alias cp='cp --interactive'
alias mv='mv --interactive'
alias rm='rm --interactive'

alias grep="grep --color=auto"

alias be="bundle exec"
alias gti="git"

alias fan-fullspeed="echo level full-speed | sudo tee /proc/acpi/ibm/fan"
alias fan-auto="echo level auto | sudo tee /proc/acpi/ibm/fan"

alias nautilus="dbus-launch nautilus"

alias ack="ack --page='less -r'"

alias reload_xdefaults="xrdb ~/.Xdefaults"

alias vpnftv="jnc -l 0 -n jaguar"

alias gourmand="du --max-depth=1 . | sort -n -r"

