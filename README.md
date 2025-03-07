# Dotfiles

My own configuration files.

### Overview
My collection of configuration files for many tools.
This configurations are to my setup and tooling, could
or couldn't work for you.

### Installing configs

There's a script called `dotfile` in repository root
that can be used to installing configurations.

No help message yet, but the script commands are:

`install` :: install a config given a name *or* all when no argument is provided.

`uninstall` :: uninstall some config *or* all when no argument provided.

`check` :: check for dependencies of a dotfile.

`list` :: will list the installable configs and their status (WIP).

`help` :: show help message (WIP).

> `NOTE` the check command checks for binary name, e.g., when check dependencies for
> bat it will check for bat binary, but some distributions has a batcat command instead
> so the check will fail.
