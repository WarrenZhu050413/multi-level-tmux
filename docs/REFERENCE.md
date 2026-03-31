# 📖 Script Reference

## Core Scripts

### tmux-goto-level
**Purpose**: Switch to a specific level (1-9)

**Usage**: 
```bash
tmux-goto-level <level>
```

**Parameters**:
- `level`: Target level (1-9)

**Behavior**:
- Updates global `@active_level`
- Scans all sessions and updates their prefix/key-table
- Activates matching sessions, sets others to passthrough
- Saves state to `~/.tmux_level_state`

**Example**:
```bash
tmux-goto-level 3  # Switch to Level 3
```

---

### tmux-level-up
**Purpose**: Move up one level with circular wrapping

**Usage**:
```bash
tmux-level-up
```

**Behavior**:
- Uses formula: `((current - 2 + 9) % 9) + 1`
- Wraps: 1→9→8→7...→2→1

**Example**:
```bash
# At Level 3
tmux-level-up  # Now at Level 2
```

---

### tmux-level-down
**Purpose**: Move down one level with circular wrapping

**Usage**:
```bash
tmux-level-down
```

**Behavior**:
- Uses formula: `(current % 9) + 1`
- Wraps: 1→2→3...→9→1

**Example**:
```bash
# At Level 8
tmux-level-down  # Now at Level 9
```

---

### tmux-start-level
**Purpose**: Create a new tmux session with level identity

**Usage**:
```bash
tmux-start-level [level] [tmux-options]
tmux-start-level --next [tmux-options]
tmux-start-level --help
```

**Parameters**:
- `level`: Level number (1-9) or `--next` for auto-increment
- `tmux-options`: Standard tmux new-session options

**Behavior**:
- Creates session with `@session_level` set
- Auto-detects level if not specified
- Sets appropriate prefix and key-table
- Configures status bar with level indicator

**Examples**:
```bash
tmux-start-level 3 -s backend      # Level 3 session named "backend"
tmux-start-level --next -s frontend # Next level from current
tmux-start-level -s test            # Auto-detect level
```

---

### tmux-level-status
**Purpose**: Format level indicator for status bar

**Usage**:
```bash
tmux-level-status [--format]
TMUX_SESSION=name tmux-level-status [--format]
```

**Formats**:
- `--visual`: `[L3:X ●●●○○○○○○]` with colors (default)
- `--compact`: `[L3:X]` or `[L3|L2]`
- `--full`: `[L3:Ctrl+X]` or `[L3:Ctrl+X|L2]`
- `--minimal`: `[3]` or `[3|2]`

**Color Coding**:
- Levels 1-3: Default color
- Levels 4-6: Orange (#[fg=colour214])
- Levels 7-9: Red (#[fg=colour196])

**Session-Specific**:
- Shows session name when `TMUX_SESSION` is set
- Active: `[mysession:L3 ✓]`
- Passthrough: `[mysession:L2→L3]`

**Example**:
```bash
# In tmux.conf
set-option -g status-right "#(tmux-level-status --visual) | %l:%M%p"
```

---

### tmux-level-help
**Purpose**: Show context-aware help for current level

**Usage**:
```bash
tmux-level-help
```

**Output**:
- Current level and state
- Available navigation commands
- Jump key reference
- Emergency escape options

**Example Output**:
```
═══════════════════════════════════════
    TMUX MULTILEVEL NAVIGATION HELP
═══════════════════════════════════════

Current Level: 3

DIRECT JUMPS (Ctrl+X then...):
  ! → Level 1    $ → Level 4    & → Level 7
  @ → Level 2    % → Level 5    * → Level 8
  # → Level 3 ✓  ^ → Level 6    ( → Level 9

SEQUENTIAL NAVIGATION:
  Ctrl+V → Next level (→ Level 4)
  Ctrl+P → Previous level (→ Level 2)

EMERGENCY: Ctrl+X ! returns to Level 1
```

---

### tmux-level-reset
**Purpose**: Emergency reset to Level 1

**Usage**:
```bash
tmux-level-reset
```

**Behavior**:
- Forces `@active_level` to 1
- Sets prefix to C-x
- Sets key-table to root
- Clears state file

**When to Use**:
- Stuck in wrong level
- Configuration corrupted
- Quick return to base

---

### tmux-add-level-bindings
**Purpose**: Apply key bindings to specific level's key-table (internal script)

**Usage**:
```bash
tmux-add-level-bindings <level>
```

**Parameters**:
- `level`: Level number (1-9)

**Behavior**:
- Adds navigation bindings to level's key-table
- Configures prefix handling
- Sets up jump shortcuts

**Note**: Usually called internally by other scripts

---

### worktree-tmux
**Purpose**: Create 4 git worktrees in 2x2 tmux layout

**Usage**:
```bash
worktree-tmux [namespace] [level]
worktree-tmux --help
```

**Parameters**:
- `namespace`: Optional identifier (default: timestamp)
- `level`: Optional tmux level (default: auto-detect)

**Behavior**:
- Creates 4 git worktrees with branches
- Sets up 2x2 pane layout
- Creates tmux session at specified/next level
- Names session as `project-namespace`

**Examples**:
```bash
worktree-tmux                    # Auto namespace, auto level
worktree-tmux backend            # "backend" namespace, auto level
worktree-tmux frontend 5         # "frontend" namespace, Level 5
```

**Created Structure**:
```
../project-namespace-1/  (branch: project-namespace-1)
../project-namespace-2/  (branch: project-namespace-2)
../project-namespace-3/  (branch: project-namespace-3)
../project-namespace-4/  (branch: project-namespace-4)
```

## File Locations

### Scripts Directory
```
~/.local/bin/tmux-multilevel/
├── tmux-goto-level
├── tmux-level-up
├── tmux-level-down
├── tmux-level-status
├── tmux-level-help
├── tmux-level-reset
├── tmux-add-level-bindings
├── tmux-start-level
└── worktree-tmux
```

### Configuration Files
```
~/.tmux.conf              # Main tmux configuration
~/.tmux_level_state       # Persistent level state (auto-created)
```

### Project Files
```
multi-level-tmux/
├── install.sh            # Installation script
├── tmux.conf            # Example configuration
├── scripts/             # Source scripts
└── docs/               # Documentation
```

## Requirements

### System Requirements
- **tmux**: Version 2.1 or higher
- **bash**: For script execution
- **git**: For worktree-tmux functionality

### Path Requirements
- `~/.local/bin` must be in PATH
- Scripts must be executable (`chmod +x`)

### tmux Features Used
- **Options**: `set-option`, `show-option`
- **Key tables**: `-T` flag for bind-key
- **Session hooks**: `set-hook -g session-created`
- **Format strings**: `#S`, `#{pane_current_path}`

## Environment Variables

### Used by Scripts
- `TMUX`: Detect if inside tmux
- `TMUX_SESSION`: Override session name for status
- `HOME`: User home directory
- `PATH`: Must include ~/.local/bin

### Set by Scripts
- `TMUX_VERSION`: Stored by tmux.conf

## Return Codes

All scripts follow standard Unix conventions:
- `0`: Success
- `1`: General error
- `2`: Invalid arguments
- `127`: Command not found

## Integration Points

### Reading State in Custom Scripts
```bash
# Get current active level
level=$(tmux show-option -gv @active_level 2>/dev/null || echo "1")

# Get session's level
session_level=$(tmux show-option -t session_name -qv @session_level)

# Check if at specific level
if [[ $(tmux show-option -gv @active_level) == "3" ]]; then
  echo "At Level 3"
fi
```

### Changing Level Programmatically
```bash
# Direct call
~/.local/bin/tmux-multilevel/tmux-goto-level 5

# With error checking
if ~/.local/bin/tmux-multilevel/tmux-goto-level 5; then
  echo "Switched to Level 5"
else
  echo "Failed to switch"
fi
```

### Creating Level-Aware Sessions
```bash
# In scripts
tmux new-session -d -s mysession \; \
  set-option @session_level 3 \; \
  set-option prefix C-x \; \
  set-option key-table root
```