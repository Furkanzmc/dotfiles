# Create an alias for `git stage`
git config --global alias.unstage 'add'
# Create an alias for `git unstage`
git config --global alias.unstage 'reset HEAD --'
# Create an alias to see the last commit `git last`
git config --global alias.last 'log -1 HEAD'
# Open GitX with `git visual`
git config --global alias.visual '!open ./ -a "GitX"'
# Use `git logall` to log all the changes
git config --global alias.logall "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# Use `git logcurrent` to log the current branch
git config --global alias.logcurrent "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
# Use `git tasks` to list the TODO and FIXME entries in the code
git config --global alias.tasks "ag 'TODO|FIXME' ./"