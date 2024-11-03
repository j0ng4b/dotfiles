# git add
alias -g ga='git add'
alias -g gaa='git add --all'
alias -g gai='git add --interactive'
alias -g gap='git add --patch'

# git branch
alias -g gb='git branch'
alias -g gba='git branch --all'
alias -g gbd='git branch --delete'
alias -g gbD='git branch --delete --force'
alias -g gbm='git branch --move'
alias -g gbM='git branch --move --force'
alias -g gbr='git branch --remote'
alias -g gbu='git branch --set-upstreat-to'

# git commit
alias -g gc='git commit'
alias -g gcm='git commit --message'
alias -g gca='git commit --amend --no-edit'
alias -g gcae='git commit --amend --edit'

# git diff
alias -g gd='git diff'
alias -g gdw='git diff --word-diff'
alias -g gds='git diff --staged'
alias -g gdsw='git diff --staged --word-diff'

# git status
alias -g gs='git status'
alias -g gsu='git status --untracked-files'
alias -g gss='git status --short'
alias -g gssu='git status --short --untracked-files'

# git fetch
alias -g gf='git fetch'
alias -g gfa='git fetch --all --tags --prune'
alias -g gfo='git fetch origin'

# git log
alias -g gl='git log'
alias -g glg='git log --graph'
alias -g glo='git log --oneline --decorate'
alias -g glog='git log --oneline --decorate --graph'
alias -g glsp='git log --stat --patch'

# git merge
alias -g gm='git merge'
alias -g gma='git merge --abort'
alias -g gmc='git merge --continue'
alias -g gms='git merge --squash'
alias -g gmff='git merge --ff-only'

