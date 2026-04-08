# xbps-install
## synchronize remote repository index files.
alias -g xi="xbps-install --sync"

## same as above but also update all system installed packages or a
## specific package.
alias -g xiu="xbps-install --sync --update"


# xbps-remove
## recursively remove packages that were installed by a package and
## aren't required by other installed packages.
alias -g xr="xbps-remove --recursive"

## removes installed package orphans that were installed automatically
## and outdated binary packages from cache.
alias -g xrc="xbps-remove --clean-cache  --remove-orphans"

## same as above but also remove packages that are not installed from
## the cache.
alias -g xrC="xbps-remove --clean-cache --clean-cache --remove-orphans"


# xbps-query
## search for packages by matching
alias -g xq="xbps-query -R --regex --search"

## lists registered packages in the package database
alias -g xql="xbps-query -R --list-pkgs"

## lists registered packages that were installed manually
alias -g xqm="xbps-query -R --list-manual-pkgs"

## lists registered packages that were installed manually
alias -g xqo="xbps-query -R --list-orphans"

## shows information of an installed package
alias -g xqs="xbps-query --show"

## shows information of a repository package
alias -g xqS="xbps-query -R --show"

## show the package files
alias -g xqf="xbps-query -R --files"

## prints the some file stored in binary package to stdout
alias -g xqF="xbps-query -R --cat"

## show the required dependencies for a package
alias -g xqd="xbps-query -R --fulldeptree --deps"

## show the reverse dependencies for a package
alias -g xqx="xbps-query -R --revdeps"
