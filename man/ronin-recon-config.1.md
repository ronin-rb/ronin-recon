# ronin-recon-config 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config - Get and set ronin-recon configuration

## SYNOPSIS

`ronin-recon config` [*options*] [*COMMAND* [...]]

## DESCRIPTION

Runs a `ronin-recon config` *COMMAND* that can get or set `ronin-recon`
configuration settings.

## ARGUMENTS

*COMMAND*
: The `ronin-recon config` command to execute.

## OPTIONS

`-V`, `--version`
: Prints the `ronin-recon` version and exits.

`-h`, `--help`
: Print help information

## COMMANDS

*disable*
: Disables a worker in the configuration file.

*enable*
: Enables a worker in the configuration file.

*get*
: Gets the concurrency or a param for a worker.

*list*
: Lists the values in the configuration file.

*set*
: Sets the concurrency or a param for a worker.

*unset*
: Unsets the concurrency or params for a worker.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-config-disable](ronin-recon-config-disable.1.md) [ronin-recon-config-enable](ronin-recon-config-enable.1.md) [ronin-recon-config-get](ronin-recon-config-get.1.md) [ronin-recon-config-list](ronin-recon-config-list.1.md) [ronin-recon-config-set](ronin-recon-config-set.1.md) [ronin-recon-config-unset](ronin-recon-config-unset.1.md)
