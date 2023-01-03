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

alias gourmand="du --max-depth=1 . | sort -n -r"

alias freeboxtv="vlc --avcodec-hw=vaapi http://mafreebox.freebox.fr/freeboxtv/playlist.m3u &"

alias caps_lock="xdotool key Caps_Lock"

alias json_view="python -m json.tool"

alias no_blank_screen="xset dpms 0 0 0 && xset s noblank  && xset s off"

# when change /etc/default/keyboard
alias reload_keyboard="udevadm trigger --subsystem-match=input --action=change"

function ssh_jump() {
  ssh -A -J $1 -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" $2
}

alias database_size="PGPASSWORD=wttj watch -c \"psql -U wttj -d postgres -c 'SELECT pg_database.datname as database_name, pg_size_pretty(pg_database_size(pg_database.datname)), pg_database_size(pg_database.datname) as size FROM pg_database ORDER by size DESC;'\""

alias gnome_dark="gsettings set org.gnome.desktop.interface color-scheme prefer-dark"
alias gnome_light="gsettings set org.gnome.desktop.interface color-scheme prefer-light"
