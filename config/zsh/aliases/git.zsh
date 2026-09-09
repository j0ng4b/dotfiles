# git add
alias ga='git add'
alias gaa='git add --all'
alias gai='git add --interactive'
alias gap='git add --patch'

# git branch
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbm='git branch --move'
alias gbM='git branch --move --force'
alias gbr='git branch --remote'
alias gbu='git branch --set-upstream-to'

function gbds() {
  local branches
  branches=$(git branch | grep -v "^\*" | fzf --multi --prompt="Select branches to delete: ")

  if [[ -n "$branches" ]]; then
    echo "$branches" | xargs git branch -d
  fi
}

function gbdm() {
  git branch --merged | grep -E -v "(^\*|main|master)" | xargs git branch -d
}

# git checkout
alias gco='git checkout'
alias gcom='git checkout main'
alias gcod='git checkout --detach'
alias gcoo='git checkout --orphan'
alias gcop='git checkout --patch'

# git clone
alias gcl='git clone'

# git commit
alias gc='git commit'
alias gcm='git commit --message'
alias gca='git commit --amend --no-edit'
alias gcae='git commit --amend --edit'
alias gcam='git commit --amend --message'
alias gce='git commit --allow-empty'
alias gcem='git commit --allow-empty --message'

# git diff
alias gd='git diff'
alias gdw='git diff --word-diff'
alias gds='git diff --staged'
alias gdsw='git diff --staged --word-diff'

# git fetch
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfA='git fetch --all --tags --prune'
alias gfo='git fetch origin'

# git log
alias gl='git log --abbrev-commit'
alias glg='git log --abbrev-commit --graph'
alias glo='git log --abbrev-commit --oneline --decorate'
alias glog='git log --abbrev-commit --oneline --decorate --graph'
alias glsp='git log --abbrev-commit --stat --patch'

# git merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms='git merge --squash'
alias gmf='git merge --ff-only'
alias gmnff='git merge --no-ff'

# git pull
alias gpl='git pull'
alias gplf='git pull --ff-only'
alias gplr='git pull --rebase'
alias gplm='git pull --no-rebase'
alias gpla='git pull --all'
alias gplA='git pull --all --prune'

# git push
alias gp='git push'
alias gpa='git push --all'
alias gpA='git push --all --force-with-lease'
alias gpp='git push --prune'
alias gppt='git push --prune --tags'
alias gpt='git push --tags'
alias gpd='git push --delete'
alias gpf='git push --force-with-lease'
alias gpF='git push --force'

# git rebase
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
alias grbo='git rebase --onto'

# git reset
alias gr='git reset'
alias grp='git reset --patch'
alias grh='git reset --hard'
alias grhp='git reset --hard --patch'
alias grs='git reset --soft'
alias grsp='git reset --soft --patch'
alias grm='git reset --mixed'
alias grmp='git reset --mixed --patch'

# git restore
alias grst='git restore'
alias grsts='git restore --staged'

# git stash
alias gst='git stash'
alias gstm='git stash push -m'
alias gstu='git stash --include-untracked'
alias gstA='git stash --all'
alias gstp='git stash pop'
alias gsta='git stash apply'
alias gstl='git stash list'
alias gsts='git stash show -p'
alias gstd='git stash drop'
alias gstc='git stash clear'

function gstS() {
  local stash
  stash=$(git stash list | fzf --prompt="Select a stash to apply: " --preview="git stash show -p {1} --color=always" | awk -F: '{print $1}')

  if [[ -n "$stash" ]]; then
    echo "Select action for $stash:"
    select action in "Pop (apply and delete)" "Apply (keep in list)" "Cancel"; do
      case $action in
        "Pop (apply and delete)" ) git stash pop "$stash"; break;;
        "Apply (keep in list)" ) git stash apply "$stash"; break;;
        "Cancel" ) break;;
      esac
    done
  fi
}

function gstD() {
  local stashes
  stashes=$(git stash list | fzf --multi --prompt="Select stashes to delete: " --preview="git stash show -p {1} --color=always" | awk -F: '{print $1}')

  if [[ -n "$stashes" ]]; then
    echo "$stashes" | xargs -I {} git stash drop {}
  fi
}

# git status
alias gs='git status'
alias gsu='git status --untracked-files'
alias gss='git status --short'
alias gssu='git status --short --untracked-files'

# git cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
