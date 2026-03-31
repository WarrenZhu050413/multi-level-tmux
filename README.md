multi-level-tmux -- navigate 9 nested tmux levels with one keypress.

Solves the "tmux inside tmux" prefix collision problem: each level gets its own prefix, and only the active level intercepts keys.

## Quick Start

Requires: tmux 3.0+, bash.

```bash
git clone https://github.com/WarrenZhu050413/multi-level-tmux.git
cd multi-level-tmux
./install.sh          # prompts for prefix keys (default: C-x / C-a)
cp tmux.conf.generated ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

Verify it works:

```
$ tmux-start-level 1 -s main
$ tmux-start-level 2 -s nested    # inside the first session
$ Ctrl+N                           # switch active level 1 → 2
```

Status bar shows: `[main:L1→L2] [●●○○○○○○○]` (passthrough) and `[nested:L2 ✓]` (active).

## Reference

| Resource | Path |
|----------|------|
| Full command reference | [docs/REFERENCE.md](docs/REFERENCE.md) |
| Customization guide | [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) |
| Git worktree integration | [docs/WORKTREE.md](docs/WORKTREE.md) |
| Troubleshooting | [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) |
| Implementation details | [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md) |
| Prefix config | `~/.local/bin/tmux-multilevel/config.sh` |

## How It Works

Two tmux options per session: `@active_level` (global) and `@session_level` (per-session). When you navigate to level N, `tmux-goto-level` scans all sessions: matching sessions get the primary prefix + `root` key-table, others get the secondary prefix + `off` key-table. Keys pass through inactive sessions to the active one.

```
tmux-goto-level 2
  ├─ session L1 → prefix=C-a, key-table=off   (passthrough)
  ├─ session L2 → prefix=C-x, key-table=root  (active)
  └─ session L3 → prefix=C-a, key-table=off   (passthrough)
```

## Usage

```bash
# Navigation
<prefix> !@#$%^&*(         # jump to level 1-9 directly
Ctrl+N                      # next level (wraps 9→1)
Ctrl+P                      # previous level (wraps 1→9)

# Session management
tmux-start-level [1-9] [tmux-opts...]   # create session at level
tmux-start-level 2 -s backend           # named session at level 2
tmux-start-level                        # auto-increment from parent

# Status bar
tmux-level-status --compact   # [session:L2 ✓]
tmux-level-status --full      # [session:L2:Ctrl+X ✓]
tmux-level-status --visual    # [session:L2 ✓] [●●○○○○○○○]

# Utilities
tmux-level-help              # show keybindings for current level
tmux-level-reset             # emergency reset to level 1
worktree-tmux [ns] [level]  # 4 git worktrees in 2x2 tmux layout
```

Config resolution: `config.sh > lib.sh defaults > C-x/C-a hardcoded`.

## Sharp Edges

- Session-created hook races with manual `set-option` -- add `sleep 0.2` between `new-session` and `set-option @session_level`.
- `worktree-tmux` creates branches in the parent directory. Clean up with `git worktree remove`.
- Bare `$var` before Unicode (`$slevel→`) confuses bash's UTF-8 parser. Use `${var}` braces.

MIT
