# ronin-recon-config-enable 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config-enable - Enables a worker in the configuration file

## SYNOPSIS

`ronin-recon config enable` [*options*] *WORKER*

## DESCRIPTION

Enables a worker in the configuration file. This will cause the worker to
automatically run by default when `ronin-recon run` is ran.

## ARGUMENTS

*WORKER*
: The worker ID to enable.

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

[ronin-recon-config-disable](ronin-recon-config-disable.1.md) [ronin-recon-config-list](ronin-recon-config-list.1.md)
