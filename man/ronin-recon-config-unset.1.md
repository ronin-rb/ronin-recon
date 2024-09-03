# ronin-recon-config-unset 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config-unset - Unsets the concurrency or params for a worker

## SYNOPSIS

`ronin-recon config unset` [*options*] {`--concurrency` *WORKER* \| `--param` *WORKER*`.`*NAME*}

## DESCRIPTION

Unsets the concurrency setting for a *WORKER* or a param value for the *WORKER*.
This will cause the *WORKER* to revert to using the default concurrency value
or the default param value.

## OPTIONS

`-C`, `--config-file` *FILE*
: Loads the configuration file from another file.

`-c`, `--concurrency` *WORKER*
: Unsets the concurrency of the *WORKER*.

`-p`, `--param` *WORKER*`.`*PARAM*
: Unsets the param value for the *PARAM* and *WORKER*.

`-h`, `--help`
: Print help information

## FILES

`~/.config/ronin-recon/config.yml`
: The path to the default configuration file for `ronin-recon`.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-config-list](ronin-recon-config-list.1.md) [ronin-recon-config-get](ronin-recon-config-get.1.md) [ronin-recon-config-set](ronin-recon-config-set.1.md)
