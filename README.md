# dotfiles

Dotfiles for macOS and (Partially) Windows.

## Favorite Command Line Tools

- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)
- [exa](https://the.exa.website/)
- [fd](https://github.com/sharkdp/fd)
- [nnn](https://github.com/jarun/nnn)
- [tmux](https://github.com/tmux/tmux)

## Powershell Profile

See [here](https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/21/understanding-the-six-powershell-profiles/) for profile paths.

Optionally check for `$profile` in Powershell and copy the file to that location.

I don't use Windows that often, so the settings for Windows is very minimal.
I mostly try to mimic the same git commands.

## Tmux

- `tmux-dump`: Dump the given session.
- `tmux-save`: Save the given session to the given file.
- `tmux-restore`: Restore a tmux session from a session file that was saved
using `tmux-save`.
- A minimal status bar configuration with session name, centered tabs and clock
on the right.

### Mappings and Aliases

- Alias `rename-pane` to `select-pane -T`.
- Alias `pane-title-on` and `pane-title-off` to `setw pane-border-status top/off`.
- `<Prefix> + h/j/k/l` to switch between panes.
- `<Prefix> |/_` to split vertically and horizontally.
- `<Prefix> + H/J/K/L` to resize pane.
- `<Prefix> + C-v/C-h` to select an even vertical pr horizontal layout.
- `<Prefix> + T` for a tiles layout.
- `<Prefix> + C-k` to clear the screen and the scrollback buffer.

## Karabiner Mappings

- Use Vi-like navigating.
    + LControl + h/j/k/l/0/b/e/4/u/d as to navigate.
    + LOption + H/J/K/L/B/E for selection.
- Map Caps Lock to Left Control on press and hold and to escape on single
  press.
- Map LControl + Spacebar to Ctrl + b

## Hammerspoon

I use Hammerspoon as a window manager.

Commmands include:

+ Tile windows on the left half of the screen.
+ Tile windows on the right half of the screen.
+ Tile windows in a grid.
+ Tile windows horizontally in the entire space.

And a few others...

Commands apply to the focused window or the windows of the application in the
current space that the window belongs to.

Checkout `hammerspoon/windows-bindings.lua` for details.

## Git Config

Add the following to your local `.gitconfig` file:

```git
[include]
    path = ~/.dotfiles/gitconfig
```
