# Keybinding Design Document

## 1. Overview

### 1.1 Purpose

Operate the following tools in a Windows environment with a unified keybinding system:

- **GlazeWM**: Tiling window manager
- **WezTerm**: Terminal emulator
- **Zellij**: Terminal multiplexer
- **LazyVim**: Neovim distribution

### 1.2 Design Principles

1. **Vim keymap as standard** - Unified directional operations with h/j/k/l across all tools
2. **Terminal input priority** - Do not interfere with terminal application operations
3. **Hierarchical namespaces** - Each tool has independent Leader/Modifier keys
4. **Cross-tool operation consistency** - Same keys for same concepts
5. **US layout** - Optimized for US keyboard layout

### 1.3 Environment

| Item | Value |
|------|-------|
| OS | Windows 11 |
| Keyboard | US layout |
| Terminal | WezTerm + Zellij |
| Editor | LazyVim (Neovim) |
| Shell | Vi mode (`set -o vi`) |

---

## 2. Constraints

### 2.1 Terminal Required Keys

The following keys used by terminal applications must **pass through to the terminal**:

| Key | Function |
|-----|----------|
| Ctrl+C | Interrupt (SIGINT) |
| Ctrl+D | EOF / Exit |
| Ctrl+L | Clear screen |
| Ctrl+Z | Suspend (SIGTSTP) |
| Ctrl+R | History search |
| Ctrl+[ | Escape |

### 2.2 GlazeWM Key Priority

GlazeWM operates at the Windows level and processes keys before applications:

```
[Keyboard] → [GlazeWM] → [WezTerm] → [Zellij] → [Vim]
```

→ **Alt keys used by GlazeWM do not reach terminal/Zellij**

### 2.3 Shell Vi Mode

Shell uses Vi mode (`set -o vi`), so Emacs mode keys (Alt+F/D etc.) can conflict with GlazeWM without issue.

---

## 3. Layer Structure

### 3.1 Layer Design

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: GlazeWM (Windows)                                  │
│   Alt + key                                                 │
│   Windows window placement, focus management                │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: WezTerm (Terminal Emulator)                        │
│   Ctrl+\ → key                                              │
│   Terminal tab/pane management, SSH connection switching    │
├─────────────────────────────────────────────────────────────┤
│ Layer 3: Zellij/tmux (Terminal Multiplexer)                 │
│   Ctrl+a → key                                              │
│   Pane/tab management within each environment               │
│   (tmux on Linux/WSL, Zellij as alternative)                │
├─────────────────────────────────────────────────────────────┤
│ Layer 4: Vim (Editor)                                       │
│   Space + key                                               │
│   Editor operations                                         │
├─────────────────────────────────────────────────────────────┤
│ Layer 5: Terminal (Pass-through)                            │
│   Ctrl+c, Ctrl+d, Ctrl+l, Ctrl+z, etc.                      │
│   Pass directly to terminal applications                    │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Usage Scenario

```
WezTerm
├── Tab1: WSL Ubuntu
│   └── Zellij Session
│       ├── Pane1: LazyVim (project editing)
│       ├── Pane2: Development tools
│       └── Pane3: git / shell
├── Tab2: SSH server-a
│   └── Zellij Session
├── Tab3: SSH server-b
│   └── Zellij Session
└── Tab4: PowerShell (Windows operations)
```

Operation examples:
- `Alt+l` → Focus right Windows window
- `Ctrl+\ → o` → Next WezTerm tab
- `Ctrl+a → l` → Right Zellij/tmux pane
- `Ctrl+a → F` → tmux-sessionizer (project picker)
- `Space + ff` → File search in Vim

---

## 4. Modifier/Leader Assignment

| Modifier | Assigned to | Purpose |
|----------|-------------|---------|
| Alt | GlazeWM | Windows window management |
| Alt+Shift | GlazeWM | Window/workspace movement |
| Ctrl+\ | WezTerm Leader | Terminal tab/pane |
| Ctrl+a | tmux/Zellij Leader | Multiplexer operations |
| Space | Vim Leader | Editor operations |
| Ctrl+single key | Pass-through | Direct to terminal |

### 4.1 Leader Key Behavior

| Tool | Leader | Timeout | Behavior after timeout |
|------|--------|---------|------------------------|
| WezTerm | Ctrl+\ | 1000ms | Key input passes to terminal |
| tmux | Ctrl+a (prefix) | - | Waits for next key |
| Zellij | Ctrl+a | None | Stays in tmux mode (Esc to exit) |

### 4.2 Leader Key Alternative Transmission

When you need to send the Leader key itself to the terminal:

| Leader | Original function | Alternative method |
|--------|-------------------|-------------------|
| Ctrl+a | Shell line beginning (Emacs mode) | Ctrl+a → a |
| Ctrl+\ | Send SIGQUIT | Not commonly used |

---

## 5. Unified Keybinding Patterns

Same keys for same operations across 3 tools (GlazeWM, Zellij, WezTerm).

| Operation | GlazeWM (Alt+) | Zellij (Ctrl+a→) | WezTerm (Ctrl+\→) |
|-----------|----------------|------------------|-------------------|
| Move left | h | h | h |
| Move down | j | j | j |
| Move up | k | k | k |
| Move right | l | l | l |
| Resize/Move left | Shift+H | Shift+H | Shift+H |
| Resize/Move down | Shift+J | Shift+J | Shift+J |
| Resize/Move up | Shift+K | Shift+K | Shift+K |
| Resize/Move right | Shift+L | Shift+L | Shift+L |
| Previous | i | i | i |
| Next | o | o | o |
| Reorder (prev) | - | Shift+I | Shift+I |
| Reorder (next) | - | Shift+O | Shift+O |
| Select by number | 1~9 | 1~9 | 1~9 |
| Close | Shift+x | x | x |
| Close tab | - | X | X |
| Pane zoom | - | f | f |
| Scroll/Copy mode | - | [ | [ |
| Search | - | / | / |

**Note**: WezTerm's `Ctrl+\ → ?` (debug overlay) and Zellij's `?` (tooltip) are different features. Zellij's tooltip is a plugin feature, not via Leader (see 8.6).

---

## 6. GlazeWM Keybinding Details

### 6.1 Default Keys and Changes

| Default Key | Default Function | Status | Changed to |
|-------------|------------------|--------|------------|
| Alt+h | focus left | ✅ Keep | - |
| Alt+j | focus down | ✅ Keep | - |
| Alt+k | focus up | ✅ Keep | - |
| Alt+l | focus right | ✅ Keep | - |
| Alt+Left | focus left | ✅ Keep | - |
| Alt+Down | focus down | ✅ Keep | - |
| Alt+Up | focus up | ✅ Keep | - |
| Alt+Right | focus right | ✅ Keep | - |
| Alt+Shift+H | move left | ✅ Keep | - |
| Alt+Shift+J | move down | ✅ Keep | - |
| Alt+Shift+K | move up | ✅ Keep | - |
| Alt+Shift+L | move right | ✅ Keep | - |
| Alt+Shift+Left | move left | ✅ Keep | - |
| Alt+Shift+Down | move down | ✅ Keep | - |
| Alt+Shift+Up | move up | ✅ Keep | - |
| Alt+Shift+Right | move right | ✅ Keep | - |
| Alt+a | prev-active-workspace | ❌ Remove | Alt+i |
| Alt+s | next-active-workspace | ❌ Remove | Alt+o |
| Alt+d | recent-workspace | ✅ Keep | - |
| Alt+1~9 | focus workspace N | ✅ Keep | - |
| Alt+Shift+1~9 | move to workspace N | ✅ Keep | - |
| Alt+Shift+a | move-workspace left | ✅ Keep | - |
| Alt+Shift+s | move-workspace down | ✅ Keep | - |
| Alt+Shift+d | move-workspace up | ✅ Keep | - |
| Alt+Shift+f | move-workspace right | ✅ Keep | - |
| Alt+u | resize --width -2% | ❌ Remove | Alt+r mode |
| Alt+p | resize --width +2% | ❌ Remove | Alt+r mode |
| Alt+i | resize --height -2% | ❌ Remove | prev-workspace |
| Alt+o | resize --height +2% | ❌ Remove | next-workspace |
| Alt+r | resize mode | ✅ Keep | - |
| Alt+v | toggle-tiling-direction | ✅ Keep | - |
| Alt+Space | wm-cycle-focus | ✅ Keep | - |
| Alt+Shift+Space | toggle-floating --centered | ✅ Keep | - |
| Alt+t | toggle-tiling | ✅ Keep | - |
| Alt+f | toggle-fullscreen | ✅ Keep | - |
| Alt+m | toggle-minimized | ✅ Keep | - |
| Alt+Shift+q | close | ❌ Remove | Alt+Shift+x |
| Alt+Shift+e | wm-exit | ✅ Keep | - |
| Alt+Shift+r | wm-reload-config | ✅ Keep | - |
| Alt+Shift+w | wm-redraw | ✅ Keep | - |
| Alt+Shift+p | wm-toggle-pause | ✅ Keep | - |
| Alt+Enter | shell-exec cmd | ✅ Keep | - |

### 6.2 New Keys

| Key | Function | Note |
|-----|----------|------|
| Alt+i | prev-active-workspace | Moved from Alt+a |
| Alt+o | next-active-workspace | Moved from Alt+s |
| Alt+Shift+x | close | Moved from Alt+Shift+q |

### 6.3 Removed Keys

| Key | Original Function | Reason |
|-----|-------------------|--------|
| Alt+a | prev-active-workspace | Moved to Alt+i |
| Alt+s | next-active-workspace | Moved to Alt+o |
| Alt+u | resize --width -2% | Use Alt+r mode |
| Alt+p | resize --width +2% | Use Alt+r mode |
| Alt+Shift+q | close | Moved to Alt+Shift+x |

### 6.4 Resize Mode (Alt+r)

After entering resize mode with Alt+r:

| Key | Action |
|-----|--------|
| h / Left | Decrease width |
| l / Right | Increase width |
| k / Up | Increase height |
| j / Down | Decrease height |
| Escape / Enter | Exit mode |

### 6.5 Final Keybinding List

| Key | Function |
|-----|----------|
| Alt+h/j/k/l | Focus movement |
| Alt+Left/Down/Up/Right | Focus movement |
| Alt+Shift+H/J/K/L | Window movement |
| Alt+Shift+Left/Down/Up/Right | Window movement |
| Alt+i | Previous workspace |
| Alt+o | Next workspace |
| Alt+d | Recent workspace |
| Alt+1~9 | Switch by workspace number |
| Alt+Shift+1~9 | Move window to workspace |
| Alt+Shift+a/s/d/f | Move workspace between monitors |
| Alt+r | Resize mode |
| Alt+v | Toggle tiling direction |
| Alt+Space | Focus cycle |
| Alt+Shift+Space | Toggle floating |
| Alt+t | Toggle tiling |
| Alt+f | Fullscreen |
| Alt+m | Minimize |
| Alt+Shift+x | Close window |
| Alt+Shift+e | Exit GlazeWM |
| Alt+Shift+r | Reload config |
| Alt+Shift+w | Redraw |
| Alt+Shift+p | Toggle pause |
| Alt+Enter | Launch terminal |

### 6.6 Error Behavior

If there's an error in the config file, GlazeWM displays an error dialog at startup. Errors are also notified when reloading config with `Alt+Shift+r`.

---

## 7. WezTerm Keybinding Details

### 7.1 Configuration Policy

Use **`disable_default_key_bindings = true`** and explicitly add only necessary keys.

### 7.2 Leader Key Configuration

```lua
leader = { key = "\\", mods = "CTRL", timeout_milliseconds = 1000 }
```

**Timeout behavior**: If the next key is not pressed within 1000ms, the Leader key input is discarded and the next key input passes directly to the terminal.

### 7.3 Tab Number Handling

WezTerm's internal API uses **0-based** tab numbers. In this design, **key 1 selects tab 1 (internally tab index 0)**.

```lua
-- Key 1 → ActivateTab=0 (first tab displayed in UI)
-- Key 2 → ActivateTab=1 (second tab displayed in UI)
-- ...
```

**Note**: WezTerm and Zellij have different internal implementations:

| Tool | Internal value for key 1 | Result |
|------|--------------------------|--------|
| WezTerm | `ActivateTab=0` | Select first tab |
| Zellij | `GoToTab 1` | Select first tab |

User experience is unified, but be aware of each tool's indexing when creating config files.

### 7.4 Keybinding List

#### Basic Operations (Direct Keys)

| Key | Function | WezTerm API |
|-----|----------|-------------|
| Ctrl+Shift+C | Copy to clipboard | `CopyTo="Clipboard"` |
| Ctrl+Shift+V | Paste from clipboard | `PasteFrom="Clipboard"` |
| Ctrl+- | Decrease font size | `DecreaseFontSize` |
| Ctrl+= | Increase font size | `IncreaseFontSize` |
| Ctrl+0 | Reset font size | `ResetFontSize` |

#### Keys After Leader (Ctrl+\ → key)

| Key | Function | WezTerm API |
|-----|----------|-------------|
| h | Move to left pane | `ActivatePaneDirection="Left"` |
| j | Move to down pane | `ActivatePaneDirection="Down"` |
| k | Move to up pane | `ActivatePaneDirection="Up"` |
| l | Move to right pane | `ActivatePaneDirection="Right"` |
| Shift+H | Resize pane left | `AdjustPaneSize={"Left", 5}` |
| Shift+J | Resize pane down | `AdjustPaneSize={"Down", 5}` |
| Shift+K | Resize pane up | `AdjustPaneSize={"Up", 5}` |
| Shift+L | Resize pane right | `AdjustPaneSize={"Right", 5}` |
| i | Previous tab | `ActivateTabRelative=-1` |
| o | Next tab | `ActivateTabRelative=1` |
| Shift+I | Move tab left | `MoveTabRelative=-1` |
| Shift+O | Move tab right | `MoveTabRelative=1` |
| 1 | Go to tab 1 | `ActivateTab=0` |
| 2 | Go to tab 2 | `ActivateTab=1` |
| 3 | Go to tab 3 | `ActivateTab=2` |
| 4 | Go to tab 4 | `ActivateTab=3` |
| 5 | Go to tab 5 | `ActivateTab=4` |
| 6 | Go to tab 6 | `ActivateTab=5` |
| 7 | Go to tab 7 | `ActivateTab=6` |
| 8 | Go to tab 8 | `ActivateTab=7` |
| 9 | Go to tab 9 | `ActivateTab=8` |
| c | New tab | `SpawnTab="CurrentPaneDomain"` |
| X | Close tab | `CloseCurrentTab{confirm=true}` |
| v | Split right (add pane on right) | `SplitHorizontal` |
| s | Split down (add pane below) | `SplitVertical` |
| x | Close pane | `CloseCurrentPane{confirm=true}` |
| f | Pane zoom | `TogglePaneZoomState` |
| [ | Scroll/Copy mode | `ActivateCopyMode` |
| / | Search | `Search={CaseSensitiveString=""}` |
| N | New window | `SpawnWindow` |
| : | Command palette | `ActivateCommandPalette` |
| Space | QuickSelect | `QuickSelect` |
| ? | Debug overlay | `ShowDebugOverlay` |

### 7.5 Split Direction Explanation

WezTerm's Split API is named by **pane arrangement after split**:

| API | Meaning | Result | Key in this design |
|-----|---------|--------|-------------------|
| `SplitHorizontal` | Arrange horizontally | Panes side by side (add pane on right) | v |
| `SplitVertical` | Arrange vertically | Panes stacked (add pane below) | s |

```
SplitHorizontal (v):          SplitVertical (s):
┌──────┬──────┐              ┌─────────────┐
│      │ NEW  │              │   CURRENT   │
│CURR. │      │              ├─────────────┤
│      │      │              │     NEW     │
└──────┴──────┘              └─────────────┘
```

### 7.6 Error Behavior

If there's a Lua syntax error in the config file, WezTerm displays an error window at startup. After fixing the config file, it automatically reloads (`automatically_reload_config = true` is default).

---

## 8. Zellij Keybinding Details

### 8.1 Configuration Policy

Use **`keybinds clear-defaults=true`** and explicitly add only necessary keys.

### 8.2 Leader Implementation

Zellij doesn't have a direct "Leader" concept, so we use **tmux mode** to implement it:

```kdl
keybinds clear-defaults=true {
    // Enter tmux mode with Ctrl+a
    shared_except "locked" {
        bind "Ctrl a" { SwitchToMode "Tmux"; }
    }

    // Define keys in tmux mode
    tmux {
        bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
        bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
        // ... and so on
    }
}
```

### 8.3 Tab Number Handling

Zellij tab numbers are **1-based** (1-indexed). `GoToTab 1` selects the first tab.

| Tool | Internal value for key 1 | Result |
|------|--------------------------|--------|
| Zellij | `GoToTab 1` | Select first tab |
| WezTerm | `ActivateTab=0` | Select first tab |

Key and display correspondence is unified, but note the different config file notation.

### 8.4 Keybinding List

#### Tmux Mode (Ctrl+a → key)

| Key | Function | Zellij Action |
|-----|----------|---------------|
| h | Move to left pane | `MoveFocus "Left"` |
| j | Move to down pane | `MoveFocus "Down"` |
| k | Move to up pane | `MoveFocus "Up"` |
| l | Move to right pane | `MoveFocus "Right"` |
| Shift+H | Resize pane left | `Resize "Increase Left"` |
| Shift+J | Resize pane down | `Resize "Increase Down"` |
| Shift+K | Resize pane up | `Resize "Increase Up"` |
| Shift+L | Resize pane right | `Resize "Increase Right"` |
| i | Previous tab | `GoToPreviousTab` |
| o | Next tab | `GoToNextTab` |
| Shift+I | Move tab left | `MoveTab "Left"` |
| Shift+O | Move tab right | `MoveTab "Right"` |
| 1~9 | Go to tab N | `GoToTab N` |
| c | New tab | `NewTab` |
| X | Close tab | `CloseTab` |
| v | Split right (add pane on right) | `NewPane "Right"` |
| s | Split down (add pane below) | `NewPane "Down"` |
| x | Close pane | `CloseFocus` |
| f | Pane zoom | `ToggleFocusFullscreen` |
| w | Toggle floating | `ToggleFloatingPanes` |
| Space | Cycle layout | `NextSwapLayout` |
| [ | Scroll/Copy mode | `SwitchToMode "Scroll"` |
| / | Search mode | `SwitchToMode "EnterSearch"` |
| d | Detach | `Detach` |
| a | Send Ctrl+a to terminal | `Write 0x01` |
| e | Popup edit | Opens Neovim popup for text input |
| F | Session manager | `LaunchOrFocusPlugin "session-manager"` |
| G | Agent deck | `Run "agent-deck"` |

### 8.5 Ctrl+a Transmission Explanation

`Write 0x01` sends ASCII code 0x01 to the terminal.

| Hex | Decimal | Meaning |
|-----|---------|---------|
| 0x01 | 1 | Ctrl+A (ASCII SOH) |

This allows sending line-beginning (Ctrl+A) in shell Emacs mode with `Ctrl+a → a`.

### 8.6 Tooltip (Keybinding Hints) Implementation

Zellij's tooltip feature is a **plugin feature**, enabled in layout configuration, not keybinds.

**Important**: This feature is used directly in Normal mode, not via Leader (Ctrl+a).

#### Layout Configuration (e.g., default.kdl)

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:compact-bar" {
            tooltip "?"
        }
    }
    pane
}
```

#### Behavior

- Press `?` in Normal mode to display keybinding hints
- Press `?` again to hide (toggle behavior)

#### Impact on Keybinds

Since the `?` key is handled by the plugin, it's not defined in keybinds configuration. Pressing `?` in tmux mode does nothing.

### 8.7 Normal Mode Keys

Keys used directly in Normal mode:

| Key | Function | Note |
|-----|----------|------|
| Ctrl+a | Enter tmux mode | Leader |
| ? | Show/hide tooltip | Plugin feature |

### 8.8 Mode Switching (for detailed operations)

From tmux mode to other modes:

| Key | Function |
|-----|----------|
| t | SwitchToMode "Tab" |
| r | SwitchToMode "Resize" |
| p | SwitchToMode "Pane" |
| m | SwitchToMode "Move" |
| S | SwitchToMode "Session" |
| g | SwitchToMode "Locked" |

#### Common (All Modes)

| Key | Function |
|-----|----------|
| Esc | SwitchToMode "Normal" |
| Enter | SwitchToMode "Normal" |

#### Session Mode

| Key | Function |
|-----|----------|
| d | Detach |
| w | Session manager (plugin) |
| c | Configuration (plugin) |

### 8.9 Error Behavior

If there's a KDL syntax error in the config file, Zellij displays an error message and exits at startup. To validate config beforehand:

```bash
zellij setup --check
```

---

## 9. tmux Keybinding Details

tmux is used on Linux/WSL as an alternative to Zellij. Keybindings are designed to match Zellij tmux mode for consistency.

### 9.1 Configuration Policy

Leader key is `Ctrl+a` (prefix), matching Zellij's tmux mode.

### 9.2 Keybinding List

#### Pane Navigation (prefix → key)

| Key | Function |
|-----|----------|
| h | Move to left pane |
| j | Move to down pane |
| k | Move to up pane |
| l | Move to right pane |
| H | Resize pane left |
| J | Resize pane down |
| K | Resize pane up |
| L | Resize pane right |

#### Window/Tab Navigation

| Key | Function |
|-----|----------|
| i | Previous window |
| o | Next window |
| I | Move window left |
| O | Move window right |
| 1-9 | Go to window N |
| c | New window |
| X | Close window |
| Tab | Last window |
| w | Session/window tree |

#### Pane Management

| Key | Function |
|-----|----------|
| v | Split right (vertical layout) |
| s | Split down (horizontal layout) |
| x | Close pane |
| f | Toggle pane zoom |
| z | Synchronize panes |
| ; | Last pane |
| b | Break pane to new window |
| Space | Cycle layout |

#### Scroll/Copy Mode

| Key | Function |
|-----|----------|
| [ | Enter copy mode |
| / | Search in copy mode |

#### Session Management

| Key | Function |
|-----|----------|
| d | Detach session |
| S | Rename session |
| N | New session (with name prompt) |
| F | tmux-sessionizer (project picker) |
| G | agent-deck (AI agent manager) |

#### Utility

| Key | Function |
|-----|----------|
| a | Send Ctrl+a to terminal |
| e | Popup edit (Neovim floating window) |

---

## 10. LazyVim Keybinding Details

**Leader**: Space

**Changes**: None (keep defaults)

#### Main Keys (Reference)

| Key | Action |
|-----|--------|
| Space+ff | File search |
| Space+fg | Grep search |
| Space+e | File explorer |
| Space+bb | Buffer switch |
| Ctrl+h/j/k/l | Window movement |
| s | Flash (search jump) |

---

## 11. Conflict Analysis

### 11.1 Conflict-Free Verification

| Key | GlazeWM | WezTerm | Zellij | Vim | Terminal | Verdict |
|-----|---------|---------|--------|-----|----------|---------|
| Alt+h/j/k/l | ○ | - | - | - | - | ✅ GlazeWM only |
| Alt+i/o | ○ | - | - | - | - | ✅ GlazeWM only |
| Ctrl+\ | - | Leader | - | - | (SIGQUIT) | ✅ WezTerm only |
| Ctrl+a | - | - | Leader | - | (line start) | ✅ Zellij only |
| Space | - | - | - | Leader | - | ✅ Vim only |
| Ctrl+c/d/l/z | - | Pass | Pass | - | ○ | ✅ Terminal pass-through |
| ? | - | After Leader | Plugin | - | - | ✅ Separated |

### 11.2 Acceptable Overlaps

| Key | Usage 1 | Usage 2 | Verdict |
|-----|---------|---------|---------|
| h/j/k/l | Zellij (after Leader) | Vim (normal) | ✅ Context separated |
| Ctrl+h/j/k/l | Vim (window move) | - | ✅ Vim only |

---

## 12. Configuration Files

### 12.1 File Locations

| Tool | Path |
|------|------|
| GlazeWM | `~/.glzr/glazewm/config.yaml` |
| WezTerm | `~/.config/wezterm/wezterm.lua` |
| tmux | `~/.config/tmux/` (modular: tmux.conf, keybindings.conf, etc.) |
| Zellij (keybinds) | `~/.config/zellij/config.kdl` |
| Zellij (layout) | `~/.config/zellij/layouts/default.kdl` |
| LazyVim | `~/.config/nvim/` |

### 12.2 Configuration Syntax Notes

Code examples in this design document are **pseudocode** to illustrate concepts. When creating actual config files, refer to each tool's official documentation for accurate syntax.

| Tool | Config Language | Official Documentation |
|------|-----------------|------------------------|
| GlazeWM | YAML | https://github.com/glzr-io/glazewm |
| WezTerm | Lua | https://wezfurlong.org/wezterm/config/ |
| tmux | tmux conf | https://github.com/tmux/tmux/wiki |
| Zellij | KDL | https://zellij.dev/documentation/ |

Special attention:

- **WezTerm**: API notation in this document (e.g., `ActivatePaneDirection="Left"`) is conceptual. Actual Lua syntax is like `{ action = wezterm.action.ActivatePaneDirection "Left", key = "h" }`.
- **Zellij**: In KDL syntax, quote usage and block formatting are important. Refer to official documentation examples.

---

## 13. Processing Flow

```
[Physical Keyboard]
       │
       ▼
[Windows OS]
       │
       ▼
[GlazeWM] ────────── Process Alt keys, pass others
       │
       ▼
[WezTerm] ─────────── Process Ctrl+\ as Leader
       │
       ▼
[Zellij] ──────────── Process Ctrl+a as Leader
       │                Plugin handles ?
       ▼
[Vim / Shell / Application]
```

---

## 14. Quick Reference

### 14.1 Leader List

| Tool | Leader | Timeout | Exit method |
|------|--------|---------|-------------|
| GlazeWM | Alt (direct) | - | - |
| WezTerm | Ctrl+\ | 1000ms | Auto timeout |
| tmux | Ctrl+a (prefix) | - | - |
| Zellij | Ctrl+a | None | Esc |
| Vim | Space | - | - |

### 14.2 Common Operations

```
# Pane/Window Movement
Alt+h/j/k/l           GlazeWM window movement
Ctrl+\ → h/j/k/l      WezTerm pane movement
Ctrl+a → h/j/k/l      Zellij pane movement

# Tab/Workspace Navigation
Alt+i/o               GlazeWM workspace prev/next
Alt+d                 GlazeWM recent workspace
Ctrl+\ → i/o          WezTerm tab prev/next
Ctrl+a → i/o          Zellij tab prev/next

# Split
Ctrl+\ → v            WezTerm split right (add pane on right)
Ctrl+\ → s            WezTerm split down (add pane below)
Ctrl+a → v            Zellij split right (add pane on right)
Ctrl+a → s            Zellij split down (add pane below)

# Close
Alt+Shift+x           GlazeWM close window
Ctrl+\ → x            WezTerm close pane
Ctrl+a → x            Zellij close pane

# Pane Zoom
Ctrl+\ → f            WezTerm pane zoom
Ctrl+a → f            Zellij pane zoom

# Scroll/Copy Mode
Ctrl+\ → [            WezTerm scroll/copy mode
Ctrl+a → [            Zellij scroll/copy mode

# Resize
Alt+r                 GlazeWM resize mode
Ctrl+\ → Shift+H/J/K/L  WezTerm pane resize
Ctrl+a → Shift+H/J/K/L  Zellij pane resize

# Font Size (WezTerm)
Ctrl+-/=/0            Decrease/Increase/Reset

# Copy/Paste (WezTerm)
Ctrl+Shift+C/V        Copy/Paste

# Session Management
Ctrl+a → d            tmux/Zellij detach
Ctrl+a → F            tmux-sessionizer (project picker)
Ctrl+a → G            agent-deck (AI agent manager)

# Popup Edit
Ctrl+a → e            tmux/Zellij popup edit (Neovim)

# Help
Ctrl+\ → ?            WezTerm debug overlay
?                     Zellij tooltip (direct in Normal mode)
```
