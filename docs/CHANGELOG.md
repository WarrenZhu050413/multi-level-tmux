# 📝 Changelog

All notable changes to Delightful Multilevel Tmux (DMT) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - Extended 9-Level System

### 🎯 Major Enhancement
Expanded from 3-level to full 9-level navigation support, enabling deeper nesting for complex development workflows.

### Added
- **9-Level Navigation**: Full support for levels 1-9
  - New keybindings: `Ctrl+X $%^&*(` for levels 4-9
  - Visual indicators for all 9 levels: `●●●●●●●●●`
  - Color coding: Orange (4-6), Red (7-9) for deep nesting warnings

- **Mathematical Navigation**:
  - Level-down formula: `(current % 9) + 1`
  - Level-up formula: `((current - 2 + 9) % 9) + 1`
  - Seamless circular wrapping without edge cases

- **Git Worktree Integration**: 
  - New `worktree-tmux` command
  - Creates 4 worktrees in 2x2 layout
  - Auto-level detection and namespace support
  - Perfect for parallel development with Claude Code

### Changed
- **Script Architecture**: All scripts now validate levels 1-9
- **Status Display**: Extended dots to show all 9 levels
- **Navigation Logic**: Replaced hardcoded cases with mathematical formulas
- **Documentation**: Expanded for 9-level system

### Technical Improvements
- Cleaner modular arithmetic for wrapping
- Consistent validation across all scripts
- Better error messages for level boundaries
- Improved performance with direct calculations

## [1.1.0] - Session-Specific Status Lines

### 🎯 Major Fix
Resolved session identity issues where multiple sessions showed incorrect names and states after tmux restart.

### Added
- **Session-Specific Status Lines**:
  - Each session shows its own name: `[backend:L2 ✓]`
  - Passthrough indicator: `[frontend:L3→L2]`
  - Session name passed via `TMUX_SESSION` environment variable

- **True Nested Sessions**:
  - Proper session hierarchy (Level 2 inside Level 1, etc.)
  - Direct `tmux new-session` instead of client switching
  - Maintains parent-child relationship

### Changed
- **Status Bar Logic**:
  - From: Global status shared by all sessions
  - To: Each session has independent status with its name
  
- **Session Creation**:
  - From: `new-session -d` with `switch-client`
  - To: Direct `new-session` with command chaining

### Fixed
- Sessions exiting immediately when created inside tmux
- Status lines showing wrong session names after restart
- Client switching breaking session hierarchy
- Detached session logic causing confusion

### Removed
- Complex detached session management
- Unnecessary `kill-session` calls
- Client switching logic
- Global status assumptions

## [1.0.0] - Initial Release

### 🎉 Features
- **3-Level Navigation System**:
  - Levels 1-3 with isolated key-tables
  - Direct jumps: `Ctrl+X !@#`
  - Sequential: `Ctrl+V` (toggle between 1-2)

- **Dual-Prefix System**:
  - Active sessions: `Ctrl+X`
  - Passthrough sessions: `Ctrl+A`

- **Visual Status Indicators**:
  - Progress dots: `●●○`
  - Active/passthrough states
  - Color coding for depth

- **Core Scripts**:
  - `tmux-goto-level`: Switch levels
  - `tmux-level-status`: Status formatting
  - `tmux-level-help`: Context help
  - `tmux-add-level-bindings`: Configure tables

### Architecture Decisions
- tmux options for state tracking
- Key-tables for input isolation
- Filesystem persistence for state recovery
- Native tmux features only (no external dependencies)

## [0.9.0] - Beta Release

### Initial Implementation
- Basic 2-level proof of concept
- Manual prefix switching
- Simple status indicator
- Core navigation logic

### Known Limitations
- Only 2 levels supported
- No session persistence
- Basic status display
- Manual configuration required

---

## Upgrade Guide

### From 1.x to 2.0
1. Update your `~/.tmux.conf` with new level bindings (4-9)
2. Run `./install.sh` to get updated scripts
3. New `worktree-tmux` command available immediately
4. Existing 3-level setups continue working unchanged

### From 0.9 to 1.0
1. Complete reinstallation recommended
2. Backup existing `~/.tmux.conf`
3. Run new installer
4. Migrate custom keybindings manually

## Future Roadmap

### Planned Features
- [ ] Custom level names/labels
- [ ] Per-level color schemes
- [ ] Integration with tmux plugins
- [ ] Automated session management
- [ ] Level-specific hooks
- [ ] Configuration profiles

### Under Consideration
- GUI configuration tool
- Browser-based visualization
- Remote session support
- Team synchronization features
- AI-assisted navigation

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```bash
git clone https://github.com/WarrenZhu050413/multi-level-tmux.git
cd multi-level-tmux
./install.sh --dev  # Installs with symlinks for development
```

### Testing
```bash
# Run test suite
./tests/run-all.sh

# Test specific version behavior
./tests/test-v2-features.sh
```

## Support

- **Issues**: [GitHub Issues](https://github.com/WarrenZhu050413/multi-level-tmux/issues)
- **Discussions**: [GitHub Discussions](https://github.com/WarrenZhu050413/multi-level-tmux/discussions)
- **Wiki**: [Documentation Wiki](https://github.com/WarrenZhu050413/multi-level-tmux/wiki)