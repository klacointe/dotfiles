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

alias brightness-high="echo 850 | sudo tee /sys/class/backlight/intel_backlight/brightness"
alias brightness-medium="echo 500 | sudo tee /sys/class/backlight/intel_backlight/brightness"
alias brightness-low="echo 222 | sudo tee /sys/class/backlight/intel_backlight/brightness"

alias nautilus="dbus-launch nautilus"

alias ack="ack --page='less -r'"

alias reload_xdefaults="xrdb ~/.Xdefaults"

alias vpnftv="jnc -l 0 -n jaguar"

alias gourmand="du --max-depth=1 . | sort -n -r"

alias freeboxtv="vlc --avcodec-hw=vaapi http://mafreebox.freebox.fr/freeboxtv/playlist.m3u &"

alias caps_lock="xdotool key Caps_Lock"

alias json_view="python -m json.tool"
