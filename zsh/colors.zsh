# Base16 Shell
BASE16_SHELL="$HOME/.base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Prefix for 256 colors:
# * foreground: 38;5;colorN
# * background: 48;5;colorN
# see .base16-shell/colortest to display colors.
eval "$(dircolors)"
export LS_COLORS="$LS_COLORS:ow=34;48;5;9:"
