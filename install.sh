#!/bin/bash
# Delightful Multilevel Tmux — Installer
# Copies scripts, creates config, generates customized tmux.conf

set -e

echo "Installing Delightful Multilevel Tmux..."

# ── Prerequisites ──────────────────────────────────────────────
command -v tmux &>/dev/null || { echo "tmux not found. Install tmux first."; exit 1; }

TMUX_VERSION=$(tmux -V | cut -d' ' -f2 | tr -d '[:alpha:]')
if [[ $(printf '%s\n' "2.1" "$TMUX_VERSION" | sort -V | head -n1) != "2.1" ]]; then
    echo "Warning: tmux $TMUX_VERSION detected. Version 2.1+ recommended."
fi

# ── Prefix Configuration ──────────────────────────────────────
validate_tmux_key() {
    [[ "$1" =~ ^(C-[a-z]|M-[a-z]|F[1-9]|F1[0-2])$ ]]
}

read_prefix_key() {
    local prompt="$1" default="$2" other="$3"
    while true; do
        read -p "$prompt" key
        key=${key:-$default}
        if ! validate_tmux_key "$key"; then
            echo "Invalid format. Use C-x, M-x, or F1"
        elif [[ -n "$other" && "$key" == "$other" ]]; then
            echo "Must be different from the other prefix"
        else
            echo "$key"; return
        fi
    done
}

echo ""
echo "Configure prefix keys:"
echo "  Primary  = active sessions    Secondary = passthrough sessions"
echo ""

primary_prefix=$(read_prefix_key "Primary prefix (default: C-x): " "C-x" "")
secondary_prefix=$(read_prefix_key "Secondary prefix (default: C-a): " "C-a" "$primary_prefix")

[[ "$primary_prefix" == "C-b" || "$secondary_prefix" == "C-b" ]] &&
    echo "Warning: C-b is tmux's default prefix. May conflict."

echo ""
echo "Primary: $primary_prefix   Secondary: $secondary_prefix"

# ── Install Scripts ────────────────────────────────────────────
INSTALL_DIR="$HOME/.local/bin/tmux-multilevel"
mkdir -p "$INSTALL_DIR"/{core,utility}

# Write config
cat > "$INSTALL_DIR/config.sh" << EOF
#!/bin/bash
# DMT prefix configuration (generated $(date +%F))
export PRIMARY_PREFIX="$primary_prefix"
export SECONDARY_PREFIX="$secondary_prefix"
EOF
chmod +x "$INSTALL_DIR/config.sh"

# Copy lib + scripts
cp scripts/lib.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/lib.sh"

for dir in core utility; do
    if [[ -d "scripts/$dir" ]]; then
        cp scripts/$dir/* "$INSTALL_DIR/$dir/"
        chmod +x "$INSTALL_DIR/$dir/"*
    fi
done

# Create direct symlinks in ~/.local/bin/ (for shell access)
for script in "$INSTALL_DIR"/{core,utility}/*; do
    [[ -f "$script" ]] || continue
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
done

# ── Optional: System-wide Claude Utilities ─────────────────────
echo ""
echo "Optional: Install Claude utilities (claude-filter, claude-resume) to /usr/local/bin?"
read -p "Install system-wide? (y/N): " install_claude
if [[ "$install_claude" =~ ^[Yy]$ ]]; then
    for util in claude-filter claude-resume; do
        src="$INSTALL_DIR/utility/$util"
        [[ -f "$src" ]] || continue
        if [[ -w /usr/local/bin ]]; then
            ln -sf "$src" "/usr/local/bin/$util"
        else
            sudo ln -sf "$src" "/usr/local/bin/$util"
        fi
        echo "  Linked $util → /usr/local/bin"
    done
fi

# ── Generate tmux.conf ────────────────────────────────────────
# Substitute prefix key into the template (tmux.conf uses C-x as default)
prefix_upper="${primary_prefix#C-}"
prefix_upper="${prefix_upper^^}"

sed -e "s|C-x|$primary_prefix|g" \
    -e "s|Ctrl+X|Ctrl+$prefix_upper|g" \
    tmux.conf > tmux.conf.generated

echo ""
echo "Generated tmux.conf.generated with prefix $primary_prefix"

# ── PATH Check ─────────────────────────────────────────────────
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo ""
    echo "Add to your shell profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

cat << END

Done! Next steps:
  1. cp tmux.conf.generated ~/.tmux.conf
  2. tmux source-file ~/.tmux.conf
  3. tmux-level-help

Prefix: $primary_prefix (active), $secondary_prefix (passthrough)
END
