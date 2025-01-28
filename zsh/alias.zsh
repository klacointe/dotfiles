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

alias brightness-high="echo 20000 | sudo tee /sys/class/backlight/intel_backlight/brightness"
alias brightness-medium="echo 15000 | sudo tee /sys/class/backlight/intel_backlight/brightness"
alias brightness-low="echo 10000 | sudo tee /sys/class/backlight/intel_backlight/brightness"

alias nautilus="dbus-launch nautilus"

alias ack="ack --page='less -r'"

alias reload_xdefaults="xrdb ~/.Xdefaults"

alias caps_lock="xdotool key Caps_Lock"

alias gnome_dark="gsettings set org.gnome.desktop.interface color-scheme prefer-dark"
alias gnome_light="gsettings set org.gnome.desktop.interface color-scheme prefer-light"

alias xtmux='tmux new -s "${PWD##*/}"'

alias git_clean_merged='git branch --merged | grep -Ev "(^\*|master|main)" | xargs git branch -d'

alias off!='killall ruby node webpack nvim beam.smp'

alias fwupdate='fwupdmgr refresh --force && fwupdmgr update'

alias ip!='echo "ipv4: "; dig -4 +short myip.opendns.com @resolver1.opendns.com; echo "ipv6: "; dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com'
