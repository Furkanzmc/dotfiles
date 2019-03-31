# dotfiles

Dotfiles for macOS

## Favorite Command Line Tools

- [fzf](https://github.com/junegunn/fzf)
- [bat](https://github.com/sharkdp/bat)
- [exa](https://the.exa.website/)
- [fd](https://github.com/sharkdp/fd)

## Powershell Profile

See [here](https://blogs.technet.microsoft.com/heyscriptingguy/2012/05/21/understanding-the-six-powershell-profiles/) for profile paths.

Optionally check for `$profile` in Powershell and copy the file to that location.

## Bash Profile

These are the available commands:

- `copy_pwd`: Copy the current directory.
- `replace_in_dir`: Replace the instances of the first parameter with the second parameter in the current directory. Depends on `rg`.
- `cd` aliases:
    + `desktop`: Change current directory to desktop.
    + `downloads`: Change current directory to downloads.
    + `icloud`: Change current directory to icloud.
- Various aliases for Git. Checkout the `bash_profile` file for more details.

## Tmux Utilities

- `tmux-dump`: Dump the given session.
- `tmux-save`: Save the given session to the given file.
- `tmux-restore`: Restore a tmux session from a session file that was saved
using `tmux-save`.
- When you source `bash_profile`, a new tmux session called `main` is
automatically created. Whenever you open a new iTerm/Terminal window, a new
window is added to the main group with a suffix that shows the number of
windows in main session.

## Karabiner Mappings

- Use Vi-like navigating.
    + Fn + h/j/k/l as Arrow Keys
    + Fn + 0/4/u/d as Home/End/Page Up/Page Down
    + Fn + y/p as Copy/Paste
    + Fn + H/J/K/L as Shift + Left/Down/Up/Right Arrow Keys. (Enables selection using Fn+Shift+h)
    + Map Caps Lock to Left Control
    + Map Right Command to Left Control
    + Map Tab to Escape
    + Map Fn + Space to Tab. (Since I use tab for completion in bash, this makes it similar to Ctrl + Space)
