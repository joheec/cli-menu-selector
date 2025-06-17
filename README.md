# cli-menu-selector

## Simplify Git Commands

```
$ gbd
Which branch(es) do you want to delete?
Select branch (Press <space> to select, <a> to toggle all, <i> to invert selection, and <enter> to proceed)
○ main [current]
● test-1
● test-2
○ test-3
Deleting selected branches...

Remaining Branches
* main
  test-3
```

Steps to Setup
1. Clone repo, `cli-menu-selector`
2. Add alias to `~/.zshrc`
   ```
   alias gbd="/PATH/TO/DIRECTORY/cli-menu-selector/git.sh \"branch delete\""
   ```
