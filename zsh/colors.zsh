# Base16 Shell
BASE16_SHELL="$HOME/dotfiles/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

# Prefix for 256 colors:
# * foreground: 38;5;colorN
# * background: 48;5;colorN
# see .base16-shell/colortest to display colors.
eval "$(dircolors)"
export LS_COLORS="$LS_COLORS:ow=34;48;5;9:"
