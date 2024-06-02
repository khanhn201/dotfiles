# Setup
```bash
git clone --bare https://github.com/1n0r1/dotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
```

Ignore some files
```bash
dotfiles update-index --skip-worktree README.md
dotfiles update-index --skip-worktree .gitignore
rm README.md
rm .gitignore
```



# References
[Dotfiles: Best way to store in a bare git repository](https://www.atlassian.com/git/tutorials/dotfiles)
