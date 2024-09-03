# ronin-recon-config-list 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config-list - Lists the values in the configuration file

## SYNOPSIS

`ronin-recon config list` [*options*]

## DESCRIPTION

Prints the enabled workers, concurrency settings, and params for each worker,
set in the configuration file.

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

[ronin-recon-config-disable](ronin-recon-config-disable.1.md) [ronin-recon-config-enable](ronin-recon-config-enable.1.md) [ronin-recon-config-get](ronin-recon-config-get.1.md) [ronin-recon-config-set](ronin-recon-config-set.1.md) [ronin-recon-config-unset](ronin-recon-config-unset.1.md)
