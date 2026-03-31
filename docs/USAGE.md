# 📚 Complete Usage Guide

## Understanding Session States

DMT sessions exist in one of two states based on level matching:

### Active State
- **Indicator**: `[Level:L3 ✓]` or `[myproject:L3 ✓]`
- **Prefix**: `Ctrl+X`
- **Behavior**: Full tmux control - create panes, windows, run commands
- **Color**: Mint green in status bar

### Passthrough State
- **Indicator**: `[Nav:L3|Session:L2]` or `[myproject:L2→L3]`
- **Prefix**: `Ctrl+A` (to avoid conflicts)
- **Behavior**: Transparent - commands pass through to child sessions
- **Color**: Soft blue in status bar

## Navigation Methods

### Direct Level Jumps
Jump instantly to any level using `Ctrl+X` followed by:

| Key | Level | Symbol |
|-----|-------|--------|
| `!` | Level 1 | Shift+1 |
| `@` | Level 2 | Shift+2 |
| `#` | Level 3 | Shift+3 |
| `$` | Level 4 | Shift+4 |
| `%` | Level 5 | Shift+5 |
| `^` | Level 6 | Shift+6 |
| `&` | Level 7 | Shift+7 |
| `*` | Level 8 | Shift+8 |
| `(` | Level 9 | Shift+9 |

**Example**: `Ctrl+X @` → Jump to Level 2

### Sequential Navigation
Move through levels one at a time:

- **`Ctrl+V`**: Go down one level (1→2→3...→9→1)
- **`Ctrl+P`**: Go up one level (9→8→7...→1→9)

These work from both active and passthrough sessions without prefix.

### Emergency Reset
- **`Ctrl+X !`**: Always returns to Level 1
- **Command line**: `tmux-level-reset`

## Creating Level-Aware Sessions

### Basic Creation
```bash
# Create a Level 3 session named "backend"
tmux-start-level 3 -s backend

# Create at next level (auto-increment)
tmux-start-level --next -s frontend

# Create with automatic level detection
tmux-start-level -s myproject  # Level 1 if outside tmux, next level if inside
```

### Options
```bash
tmux-start-level [level] [tmux-options]

# Examples:
tmux-start-level 2                    # Level 2, auto-named
tmux-start-level 3 -s project         # Level 3, named "project"
tmux-start-level 4 -s work -d         # Level 4, detached
tmux-start-level --next -s test       # Next level from current
```

## Status Bar Formats

Configure how the level indicator appears:

### Visual Format (Default)
```bash
tmux-level-status --visual
```
Output: `[L3:X ●●●○○○○○○]` with color coding:
- Levels 1-3: Default color
- Levels 4-6: Orange (medium nesting)
- Levels 7-9: Red (deep nesting)

### Compact Format
```bash
tmux-level-status --compact
```
- Active: `[L3:X]`
- Passthrough: `[L3|L2]`

### Full Format
```bash
tmux-level-status --full
```
- Active: `[L3:Ctrl+X]`
- Passthrough: `[L3:Ctrl+X|L2]`

### Minimal Format
```bash
tmux-level-status --minimal
```
- Active: `[3]`
- Passthrough: `[3|2]`

### Session-Specific Status (v1.1.0+)
Each session shows its own name:
```bash
[myproject:L2 ✓]     # "myproject" session at Level 2 (active)
[backend:L3→L2]       # "backend" session at Level 3 (passthrough, L2 active)
```

## Workflow Examples

### Example 1: Basic Multi-Level Development
```bash
# Start at Level 1 (default tmux)
tmux new -s main

# Create a Level 2 session for backend work
tmux-start-level 2 -s backend
# Now at Level 2, can create panes normally

# Create a Level 3 session for testing
tmux-start-level 3 -s testing
# Now at Level 3

# Navigate back to Level 2
Ctrl+X @  # Backend session becomes active again

# Quick jump to Level 1
Ctrl+X !  # Back to main session
```

### Example 2: Nested Remote Sessions
```bash
# Level 1: Local development
tmux new -s local

# Level 2: SSH to staging server
tmux-start-level 2 -s staging
ssh staging-server
tmux attach  # Remote tmux

# Level 3: SSH to production from staging
tmux-start-level 3 -s production
ssh prod-server
tmux attach  # Another remote tmux

# Navigate freely between all three levels
Ctrl+X !  # Local
Ctrl+X @  # Staging
Ctrl+X #  # Production
```

### Example 3: Quick Context Switching
```bash
# Working at Level 3
Ctrl+V    # Down to Level 4
Ctrl+V    # Down to Level 5
Ctrl+P    # Back up to Level 4
Ctrl+P    # Back up to Level 3

# Jump directly where needed
Ctrl+X &  # Straight to Level 7
```

## Help Commands

### Interactive Help
```bash
# Show current level and available commands
tmux-level-help

# Output includes:
# - Current level
# - Active/passthrough state
# - Navigation commands
# - Jump shortcuts
```

### Status Format Help
```bash
# Show all available status formats
tmux-level-status --help
```

### Session Creation Help
```bash
# Show session creation options
tmux-start-level --help
```

## Best Practices

1. **Use meaningful session names**: Makes status bar more informative
2. **Start with lower levels**: Keep Level 1 for primary work
3. **Use sequential navigation**: For exploring nearby levels
4. **Use direct jumps**: When you know exactly where to go
5. **Emergency reset**: Remember `Ctrl+X !` always goes to Level 1

## Tips and Tricks

### Check Current State
```bash
# From command line
tmux show-option -gv @active_level

# See all sessions and their levels
tmux list-sessions
for s in $(tmux list-sessions -F '#S'); do
  echo "$s: Level $(tmux show-option -t $s -qv @session_level)"
done
```

### Scripting Integration
```bash
# Get current level in scripts
current_level=$(tmux show-option -gv @active_level 2>/dev/null || echo "1")

# Change level programmatically
~/.local/bin/tmux-multilevel/tmux-goto-level 5

# Create session at specific level
tmux-start-level 3 -s automated -d
```

### Visual Cues
- **Green tint**: You're in an active session
- **Blue tint**: You're in passthrough mode
- **Dots**: Quick visual of your depth
- **Session name**: Always know which session you're in