# xbps-install
## synchronize remote repository index files.
alias xi="xbps-install --sync"

## same as above but also update all system installed packages or a
## specific package.
alias xiu="xbps-install --sync --update"


# xbps-remove
## recursively remove packages that were installed by a package and
## aren't required by other installed packages.
alias xr="xbps-remove --recursive"

## removes installed package orphans that were installed automatically
## and outdated binary packages from cache.
alias xrc="xbps-remove --clean-cache  --remove-orphans"

## same as above but also remove packages that are not installed from
## the cache.
alias xrC="xbps-remove --clean-cache --clean-cache --remove-orphans"


# xbps-query
## search for packages by matching
alias xq="xbps-query -R --regex --search"

## lists registered packages in the package database
alias xql="xbps-query -R --list-pkgs"

## lists registered packages that were installed manually
alias xqm="xbps-query -R --list-manual-pkgs"

## lists registered packages that were installed manually
alias xqo="xbps-query -R --list-orphans"

## shows information of an installed package
alias xqs="xbps-query --show"

## shows information of a repository package
alias xqS="xbps-query -R --show"

## show the package files
alias xqf="xbps-query -R --files"

## prints the some file stored in binary package to stdout
alias xqF="xbps-query -R --cat"

## show the required dependencies for a package
alias xqd="xbps-query -R --fulldeptree --deps"

## show the reverse dependencies for a package
alias xqx="xbps-query -R --revdeps"
