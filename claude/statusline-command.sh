#!/bin/bash
input=$(cat)

# Model
MODEL=$(echo "$input" | jq -r '.model.display_name')

# Session cost
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
COST_FMT=$(printf '$%.2f' "$COST")

# Context window
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
fmt_tok() {
    if [ "$1" -ge 1000 ]; then echo "$1" | awk '{printf "%.1fk", $1/1000}'
    else echo "$1"; fi
}
TOK_IN=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
TOK_OUT=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
TOK_FMT="📥$(fmt_tok "$TOK_IN") 📤$(fmt_tok "$TOK_OUT")"

# Duration
format_duration() {
    local s=$1 d h m
    d=$((s / 86400)); s=$((s % 86400))
    h=$((s / 3600));  s=$((s % 3600))
    m=$((s / 60));    s=$((s % 60))
    if   [ "$d" -gt 0 ]; then printf "%dd%02dh" "$d" "$h"
    elif [ "$h" -gt 0 ]; then printf "%dh%02dm" "$h" "$m"
    elif [ "$m" -gt 0 ]; then printf "%dm%02ds" "$m" "$s"
    else printf "%ds" "$s"; fi
}

DUR_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DUR_FMT=$(format_duration $((DUR_MS / 1000)))

# 5-hour rate limit (Pro/Max only, absent otherwise)
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
RESETS_AT=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

# Colors
GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
CYAN='\033[36m'; DIM='\033[2m'; RESET='\033[0m'

# Context color
if [ "$PCT" -ge 90 ]; then CTX_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then CTX_COLOR="$YELLOW"
else CTX_COLOR="$GREEN"; fi

# Progress bar
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

# Rate limit + time remaining
RATE_INFO=""
if [ -n "$RESETS_AT" ]; then
    NOW=$(date +%s)
    REMAINING=$((RESETS_AT - NOW))
    if [ "$REMAINING" -gt 0 ]; then
        RATE_INFO="⏳ $(format_duration "$REMAINING") left"
    fi
    if [ -n "$RATE_5H" ]; then
        RATE_PCT=$(printf '%.0f' "$RATE_5H")
        if [ "$RATE_PCT" -ge 80 ]; then RATE_COLOR="$RED"
        elif [ "$RATE_PCT" -ge 50 ]; then RATE_COLOR="$YELLOW"
        else RATE_COLOR="$GREEN"; fi
        RATE_INFO="${RATE_INFO} (${RATE_COLOR}${RATE_PCT}%${RESET} used)"
    fi
fi

# 7-day rate limit
RATE_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RESETS_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RATE_7D_INFO=""
if [ -n "$RESETS_7D" ]; then
    NOW=$(date +%s)
    REM_7D=$((RESETS_7D - NOW))
    if [ "$REM_7D" -gt 0 ]; then
        RATE_7D_INFO=" | 📅 $(format_duration "$REM_7D") left"
    fi
    if [ -n "$RATE_7D" ]; then
        RATE_7D_PCT=$(printf '%.0f' "$RATE_7D")
        if [ "$RATE_7D_PCT" -ge 80 ]; then R7_COLOR="$RED"
        elif [ "$RATE_7D_PCT" -ge 50 ]; then R7_COLOR="$YELLOW"
        else R7_COLOR="$GREEN"; fi
        RATE_7D_INFO="${RATE_7D_INFO} (${R7_COLOR}${RATE_7D_PCT}%${RESET} used)"
    fi
fi


DIR=$(echo "$input" | jq -r '.workspace.current_dir')
WORKTREE=$(echo "$input" | jq -r '.worktree // empty')
WORKTREE_INFO=""
[ -n "$WORKTREE" ] && WORKTREE_INFO=" | 🌳 $WORKTREE"

OUT="📁 ${DIR##*/}${WORKTREE_INFO} | ${CYAN}🤖 $MODEL${RESET} | 💰 ${YELLOW}${COST_FMT}${RESET} | 🪙 ${CTX_COLOR}${BAR} ${PCT}% ${TOK_FMT}${RESET} | ⏱️${DUR_FMT}"
[ -n "$RATE_INFO" ] && OUT="${OUT} | ${RATE_INFO}"
OUT="${OUT}${RATE_7D_INFO}"
echo -e "$OUT"
