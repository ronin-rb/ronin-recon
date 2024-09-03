# ronin-recon-config-disable 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config-disable - Disables a worker in the configuration file

## SYNOPSIS

`ronin-recon config disable` [*options*] *WORKER*

## DESCRIPTION

Disables a worker in the configuration file. This will prevent the worker from
running by default when `ronin-recon run` is ran.

## ARGUMENTS

*WORKER*
: The worker ID to disable.

## OPTIONS

`-C`, `--config-file` *FILE*
: Loads the configuration file from another file.

`-h`, `--help`
: Print help information

## FILES

`~/.config/ronin-recon/config.yml`
: The path to the default configuration file for `ronin-recon`.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-config-enable](ronin-recon-config-enable.1.md) [ronin-recon-config-list](ronin-recon-config-list.1.md)
