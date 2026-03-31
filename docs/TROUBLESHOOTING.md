# 🚨 Troubleshooting Guide

## Common Issues

### Can't Escape from Deep Levels

**Symptoms**: Stuck at a high level (7, 8, or 9) and can't navigate back

**Solutions**:
```bash
# Option 1: Emergency jump to Level 1
Ctrl+X !

# Option 2: Command line reset
tmux-level-reset

# Option 3: Sequential navigation
Ctrl+P  # Repeat until at Level 1

# Option 4: Check current level and navigate
tmux-level-help  # Shows current level and options
```

---

### Scripts Not Found

**Symptoms**: `command not found: tmux-goto-level`

**Diagnosis**:
```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep "$HOME/.local/bin"

# Check if scripts exist
ls -la ~/.local/bin/tmux-multilevel/

# Check if scripts are executable
ls -la ~/.local/bin/tmux-multilevel/tmux-goto-level
```

**Solutions**:
```bash
# Add to PATH (bash)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Add to PATH (zsh)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Make scripts executable
chmod +x ~/.local/bin/tmux-multilevel/*

# Reinstall if missing
cd multi-level-tmux
./install.sh
```

---

### Key Bindings Not Working

**Symptoms**: Ctrl+X @ doesn't jump to Level 2

**Diagnosis**:
```bash
# Check if binding exists
tmux list-keys | grep "@"

# Test script directly
~/.local/bin/tmux-multilevel/tmux-goto-level 2

# Check tmux version (need 2.1+)
tmux -V
```

**Solutions**:
```bash
# Reload configuration
tmux source-file ~/.tmux.conf

# Check for errors in config
tmux source-file ~/.tmux.conf 2>&1

# Verify prefix key
tmux show-options -g prefix

# Reset to defaults
tmux-level-reset
tmux source-file ~/.tmux.conf
```

---

### Status Bar Not Updating

**Symptoms**: Level indicator shows wrong level or doesn't update

**Diagnosis**:
```bash
# Test status script directly
~/.local/bin/tmux-multilevel/tmux-level-status --visual

# Check status interval
tmux show-options -g status-interval

# Test with session name
TMUX_SESSION=mysession tmux-level-status --compact

# Check current level
tmux show-option -gv @active_level
```

**Solutions**:
```bash
# Set faster update interval
tmux set-option -g status-interval 1

# Fix status-right setting
tmux set-option -g status-right "#(~/.local/bin/tmux-multilevel/tmux-level-status --visual) | %l:%M%p"

# Refresh client
tmux refresh-client

# Restart status bar
tmux set-option -g status off
tmux set-option -g status on
```

---

### Nested Sessions Not Working

**Symptoms**: `tmux-start-level` doesn't create proper nested sessions

**Diagnosis**:
```bash
# List all sessions
tmux list-sessions

# Check session level
tmux show-option -t session_name @session_level

# Verify session state
for s in $(tmux list-sessions -F '#S'); do
  echo "$s: Level $(tmux show-option -t $s -qv @session_level)"
done
```

**Solutions**:
```bash
# Create session manually
tmux new-session -s test \; \
  set-option @session_level "2" \; \
  set-option prefix C-x \; \
  set-option key-table root

# Kill and recreate problematic session
tmux kill-session -t problematic
tmux-start-level 2 -s problematic
```

---

### Level State Corruption

**Symptoms**: Wrong level shown, inconsistent behavior

**Diagnosis**:
```bash
# Check global level
tmux show-option -gv @active_level

# Check state file
cat ~/.tmux_level_state

# Compare states
echo "Global: $(tmux show-option -gv @active_level)"
echo "File: $(cat ~/.tmux_level_state)"
```

**Solutions**:
```bash
# Reset to clean state
tmux-level-reset

# Remove corrupted state file
rm ~/.tmux_level_state
tmux-level-reset

# Manually set level
tmux set-option -g @active_level 1
echo "1" > ~/.tmux_level_state
```

---

### Worktree-tmux Errors

#### Session Already Exists
```bash
Error: tmux session 'project-backend' already exists
```

**Solution**:
```bash
# Attach to existing session
tmux attach -t project-backend

# Or kill and recreate
tmux kill-session -t project-backend
worktree-tmux backend
```

#### Worktree Already Exists
```bash
Error: '../project-backend-1' already exists
```

**Solution**:
```bash
# Remove old worktrees
git worktree remove ../project-backend-1
git worktree remove ../project-backend-2
git worktree remove ../project-backend-3
git worktree remove ../project-backend-4

# Or prune all
git worktree prune
```

#### Not in Git Repository
```bash
Error: Not in a git repository
```

**Solution**:
```bash
# Initialize git
git init
git add .
git commit -m "Initial commit"

# Then retry
worktree-tmux backend
```

---

### Copy Mode Conflicts

**Symptoms**: Ctrl+V doesn't navigate levels in copy mode

**Explanation**: In copy mode, Ctrl+V is used for rectangle selection

**Solution**:
```bash
# Use sequential navigation outside copy mode
# Exit copy mode first (q or Escape)
# Then use Ctrl+V for level navigation

# Or use direct jumps instead
Ctrl+X @  # Jump to Level 2
Ctrl+X #  # Jump to Level 3
```

---

### Permission Denied Errors

**Symptoms**: `permission denied: tmux-goto-level`

**Solutions**:
```bash
# Fix all script permissions
chmod +x ~/.local/bin/tmux-multilevel/*

# Check directory permissions
ls -ld ~/.local/bin/tmux-multilevel/

# Fix directory if needed
chmod 755 ~/.local/bin/tmux-multilevel
```

---

## Debug Commands

### Check System State
```bash
# Complete system check
echo "=== DMT System Check ==="
echo "tmux version: $(tmux -V)"
echo "Current level: $(tmux show-option -gv @active_level 2>/dev/null || echo 'not set')"
echo "State file: $(cat ~/.tmux_level_state 2>/dev/null || echo 'not found')"
echo "PATH includes ~/.local/bin: $(echo $PATH | grep -q "$HOME/.local/bin" && echo 'yes' || echo 'no')"
echo "Scripts installed: $(ls ~/.local/bin/tmux-multilevel/ 2>/dev/null | wc -l) files"
echo "Current prefix: $(tmux show-option -g prefix)"
echo "Current key-table: $(tmux show-option -g key-table 2>/dev/null || echo 'root')"
```

### List All Level Bindings
```bash
# Show all level-related key bindings
tmux list-keys | grep -E "(run-shell.*level|[!@#\$%^&*()])"
```

### Test Navigation Sequence
```bash
# Automated test of navigation
echo "Starting at Level $(tmux show-option -gv @active_level)"
tmux-goto-level 1 && echo "✓ Level 1"
sleep 1
tmux-goto-level 5 && echo "✓ Level 5"
sleep 1
tmux-goto-level 9 && echo "✓ Level 9"
sleep 1
tmux-level-reset && echo "✓ Reset to Level 1"
```

### Monitor Level Changes
```bash
# Watch level changes in real-time
watch -n 0.5 'tmux show-option -gv @active_level'
```

## Getting Help

### Built-in Help
```bash
# Navigation help
tmux-level-help

# Status format options
tmux-level-status --help

# Session creation help
tmux-start-level --help

# Worktree help
worktree-tmux --help
```

### Collecting Debug Information
When reporting issues, include:

```bash
# System information
tmux -V
echo $SHELL
uname -a

# DMT state
tmux show-option -gv @active_level
cat ~/.tmux_level_state
ls -la ~/.local/bin/tmux-multilevel/

# Configuration snippet
grep -A5 -B5 "MULTILEVEL" ~/.tmux.conf

# Error messages (if any)
tmux-goto-level 3 2>&1
```

## Emergency Recovery

### Complete Reset
```bash
#!/bin/bash
# Emergency recovery script

echo "Performing DMT emergency recovery..."

# Reset tmux state
tmux set-option -g @active_level 1 2>/dev/null
tmux set-option -g prefix C-x 2>/dev/null
tmux set-option -g key-table root 2>/dev/null

# Clear state file
rm -f ~/.tmux_level_state
echo "1" > ~/.tmux_level_state

# Reload configuration
tmux source-file ~/.tmux.conf 2>/dev/null

# Reset all sessions
for session in $(tmux list-sessions -F '#S' 2>/dev/null); do
  tmux set-option -t "$session" prefix C-x 2>/dev/null
  tmux set-option -t "$session" key-table root 2>/dev/null
done

echo "Recovery complete. You are now at Level 1."
```

### Uninstall and Reinstall
```bash
# Complete removal
rm -rf ~/.local/bin/tmux-multilevel
rm -f ~/.tmux_level_state

# Remove from tmux.conf
# Manually edit ~/.tmux.conf and remove the multilevel section

# Reinstall
git clone https://github.com/WarrenZhu050413/multi-level-tmux.git
cd multi-level-tmux
./install.sh
```