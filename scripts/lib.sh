#!/bin/bash
# lib.sh — Shared library for Delightful Multilevel Tmux (DMT)
#
# Source this at the top of every DMT script:
#   source "$HOME/.local/bin/tmux-multilevel/lib.sh"
#
# Provides:
#   $PRIMARY_PREFIX, $SECONDARY_PREFIX, $DMT_DIR
#   detect_session_level(), active_level(), die()

DMT_DIR="${DMT_DIR:-$HOME/.local/bin/tmux-multilevel}"

# Load user's prefix configuration; fall back to defaults
[[ -f "$DMT_DIR/config.sh" ]] && source "$DMT_DIR/config.sh"
: "${PRIMARY_PREFIX:=C-x}"
: "${SECONDARY_PREFIX:=C-a}"

# Return @session_level for a tmux session (default: 1)
detect_session_level() {
    local session="${1:-$(tmux display-message -p '#S' 2>/dev/null)}"
    [[ -n "$session" ]] || { echo 1; return; }
    local lvl
    lvl=$(tmux show-option -t "$session" -v @session_level 2>/dev/null)
    echo "${lvl:-1}"
}

# Return the global @active_level (default: 1)
active_level() {
    local lvl
    lvl=$(tmux show-option -gv @active_level 2>/dev/null)
    echo "${lvl:-1}"
}

# Print error to stderr and exit
die() { printf '❌ %s\n' "$1" >&2; exit "${2:-1}"; }
