# 🔧 Customization Guide

This guide shows exactly how to adapt Delightful Multilevel Tmux to your existing setup with simple character-level changes.

## 📋 Table of Contents

- [Common Scenarios](#common-scenarios)
- [Key Binding Reference](#key-binding-reference) 
- [Status Bar Customization](#status-bar-customization)
- [Conflict Resolution](#conflict-resolution)
- [Advanced Customization](#advanced-customization)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Common Scenarios

### Scenario 1: Different Main Prefix

#### Using Ctrl+A Instead of Ctrl+X

If you prefer the traditional tmux prefix (or already use Ctrl+X for something else):

**🔍 Find these lines in your ~/.tmux.conf:**
```bash
unbind C-x
set -g prefix C-x
bind C-x send-prefix
```

**✏️ Change to:**
```bash
unbind C-a
set -g prefix C-a
bind C-a send-prefix
```

**🎨 Update status bar reference:**
```bash
# Find this comment:
# Shows [L3:X ●●●○○○○○○] format

# Change to:
# Shows [L3:A ●●●○○○○○○] format
```

### Scenario 2: Different Navigation Keys  

#### Using Ctrl+J/K Instead of Ctrl+V/B

If Ctrl+V conflicts with paste or Ctrl+P with your existing prefix:

**🔍 Find these lines:**
```bash
bind -T root C-v run-shell '~/.local/bin/tmux-multilevel/tmux-level-down'
bind -T root C-p run-shell'
```

**✏️ Change to:**
```bash
bind -T root C-j run-shell '~/.local/bin/tmux-multilevel/tmux-level-down'
bind -T root C-k run-shell '~/.local/bin/tmux-multilevel/tmux-level-up'
```

**❗ Important:** You'll also need to update all level key-tables. Run this after making the change:
```bash
# Update all level bindings with your new keys
for i in {2..9}; do ~/.local/bin/tmux-multilevel/tmux-add-level-bindings $i; done
```

### Scenario 3: Different Jump Symbols

#### Using Numbers 1-9 Instead of !@#$%^&*()

If the symbol keys are hard to reach or conflict:

**🔍 Find these lines:**
```bash
bind ! run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'
bind @ run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 2'
bind '#' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 3'
bind '$' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 4'
bind % run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 5'
bind '^' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 6'
bind '&' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 7'
bind '*' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 8'
bind '(' run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 9'
```

**✏️ Change to:**
```bash
bind 1 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'
bind 2 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 2'
bind 3 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 3'
bind 4 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 4'
bind 5 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 5'
bind 6 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 6'
bind 7 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 7'
bind 8 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 8'
bind 9 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 9'
```

**⚠️ Note:** This conflicts with tmux's default window switching. You may want to use F1-F9 instead:
```bash
bind F1 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'
bind F2 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 2'
# etc.
```

---

## 🎹 Key Binding Reference

### Default Key Bindings
| Key | Action |
|-----|--------|
| `Ctrl+X !` | Jump to Level 1 |
| `Ctrl+X @` | Jump to Level 2 |
| `Ctrl+X #` | Jump to Level 3 |
| `Ctrl+X $` | Jump to Level 4 |
| `Ctrl+X %` | Jump to Level 5 |
| `Ctrl+X ^` | Jump to Level 6 |
| `Ctrl+X &` | Jump to Level 7 |
| `Ctrl+X *` | Jump to Level 8 |
| `Ctrl+X (` | Jump to Level 9 |
| `Ctrl+V` | Go down one level |
| `Ctrl+P` | Go up one level |

### Easy Substitution Patterns
| Component | Find | Replace With | Example |
|-----------|------|-------------|---------|
| Main Prefix | `C-x` | `C-a` | Traditional tmux |
| Navigation Down | `C-v` | `C-j` | Vim-like |
| Navigation Up | `C-b` | `C-k` | Vim-like |
| Symbol Keys | `!@#` | `123` | Numbers |
| Symbol Keys | `!@#` | `F1 F2 F3` | Function keys |

---

## 🎨 Status Bar Customization

### Change Status Format
**🔍 Find this line:**
```bash
set-option -g status-right "#(~/.local/bin/tmux-multilevel/tmux-level-status --visual) #{?client_prefix,[ACTIVE],} | %l:%M%p"
```

**🎯 Available formats:**
```bash
# Detailed with dots (default)
--visual     # [L3:X ●●●○○○○○○]

# Simple text
--compact    # [L3:X]
--full       # [L3:Ctrl+X]
--minimal    # [3]
```

### Status Bar Position
```bash
# Move to left side:
set-option -g status-left "#(tmux-level-status --compact)"
set-option -g status-right "%l:%M%p"

# Custom position:
set-option -g status-right "Battery | #(tmux-level-status --visual) | %l:%M%p"
```

### Color Customization
The color coding is built into the status script:
- **Levels 1-3**: Default color (shallow nesting)
- **Levels 4-6**: Orange `#[fg=colour214]` (medium nesting)
- **Levels 7-9**: Red `#[fg=colour196]` (deep nesting warning)

To change colors, edit `~/.local/bin/tmux-multilevel/tmux-level-status`:
```bash
# Find these lines and change the colors:
echo "#[fg=colour196]${output}#[default]"  # Red -> your color
echo "#[fg=colour214]${output}#[default]"  # Orange -> your color
```

---

## ⚠️ Conflict Resolution

### Check Existing Key Bindings
```bash
# See all current bindings:
tmux list-keys

# Check specific key:
tmux list-keys | grep "C-v"

# Check what's bound to a symbol:
tmux list-keys | grep "!"
```

### Common Conflicts & Solutions

#### Ctrl+V (Paste Conflict)
**Problem:** `Ctrl+V` is commonly used for paste in some terminals.
**Solution:** Use `Ctrl+J` for down navigation:
```bash
bind -T root C-j run-shell '~/.local/bin/tmux-multilevel/tmux-level-down'
```

#### Ctrl+P (Prefix Conflict)  
**Problem:** `Ctrl+P` is the default tmux prefix.
**Solution:** Use `Ctrl+K` for up navigation:
```bash
bind -T root C-k run-shell '~/.local/bin/tmux-multilevel/tmux-level-up'
```

#### Symbol Key Conflicts (!@# etc.)
**Problem:** Shell uses `!` for history expansion, `#` for comments.
**Solution:** Use function keys or numbers:
```bash
# Function keys (F1-F9)
bind F1 run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'

# Or letters (a-i)  
bind a run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'
```

#### Window Number Conflicts (1-9)
**Problem:** Numbers 1-9 are used for window switching.
**Solution:** Use letters or keep symbols:
```bash
# Letters a-i
bind a run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 1'
bind b run-shell '~/.local/bin/tmux-multilevel/tmux-goto-level 2'
# etc.
```

### Testing Changes
```bash
# Test your changes:
tmux source-file ~/.tmux.conf

# Verify binding works:
tmux-level-help

# Test specific level:
tmux-goto-level 3
tmux-level-status
```

---

## 🚀 Advanced Customization

### Custom Status Formats
Create your own status format by modifying the status script:

```bash
# Edit ~/.local/bin/tmux-multilevel/tmux-level-status
# Add a new format option:

--custom|custom)
    # Your custom format here
    output="Level ${current_level} of 9"
    ;;
```

### Different Key-Table Names
If you want different names for the key tables:

```bash
# Edit ~/.local/bin/tmux-multilevel/tmux-goto-level
# Change the KEY_TABLES array:
declare -a KEY_TABLES=("root" "ssh2" "ssh3" "ssh4" ...)
```

### Integration with Existing Scripts
```bash
# Get current level in your own scripts:
current_level=$(tmux show-option -gv @current_level 2>/dev/null || echo "1")

# Change level programmatically:
~/.local/bin/tmux-multilevel/tmux-goto-level 5

# Check if multilevel system is active:
if tmux show-option -gq @current_level > /dev/null; then
    echo "Multilevel system active"
fi
```

---

## 🔍 Troubleshooting

### Changes Not Taking Effect
```bash
# Make sure you reloaded:
tmux source-file ~/.tmux.conf

# Check if configuration has syntax errors:
tmux source-file ~/.tmux.conf 2>&1

# Verify scripts are executable:
ls -la ~/.local/bin/tmux-multilevel/
```

### Key Bindings Not Working
```bash
# Check if scripts exist and are executable:
which tmux-goto-level

# Test script directly:
~/.local/bin/tmux-multilevel/tmux-goto-level 2

# Check PATH includes ~/.local/bin:
echo $PATH | grep "$HOME/.local/bin"
```

### Status Bar Not Updating
```bash
# Test status script directly:
~/.local/bin/tmux-multilevel/tmux-level-status --visual

# Check status interval:
tmux show-options -g status-interval

# Increase update frequency:
set-option -g status-interval 1
```

### Level State Corruption
```bash
# Check current state:
tmux show-option -gv @current_level
cat ~/.tmux_level_state

# Reset to clean state:
~/.local/bin/tmux-multilevel/tmux-level-reset

# Remove state file if corrupted:
rm ~/.tmux_level_state
```

### Permission Issues
```bash
# Fix script permissions:
chmod +x ~/.local/bin/tmux-multilevel/*

# Check if directory exists:
ls -la ~/.local/bin/tmux-multilevel/
```

---

## 📞 Getting Help

1. **Built-in Help:**
   ```bash
   tmux-level-help                # Current level help
   tmux-level-status --help       # Status format options
   ```

2. **Debug Current State:**
   ```bash
   tmux show-options -g | grep @current_level
   tmux show-options -g key-table
   tmux list-keys | head -10
   ```

3. **Test Installation:**
   ```bash
   # Run the test sequence:
   tmux-level-reset
   tmux-level-status
   tmux-goto-level 3
   tmux-level-status
   tmux-goto-level 1
   ```

4. **Report Issues:**
   Include this information when reporting problems:
   - tmux version: `tmux -V`  
   - Shell: `echo $SHELL`
   - OS: `uname -a`
   - Config snippet causing issues
   - Error messages

---

**Remember:** Most customization is just changing individual characters. Start small, test each change, and build up your perfect configuration! 🎯