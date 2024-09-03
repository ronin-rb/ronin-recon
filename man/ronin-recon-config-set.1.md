# ronin-recon-config-set 1 "2024-09-03" Ronin Recon "User Manuals"

## NAME

ronin-recon-config-set - Sets the concurrency or a param for a worker

## SYNOPSIS

`ronin-recon config set` [*options*] {`--concurrency` *WORKER*`=`*NUM* \| `--param` *WORKER*`.`*NAME*`=`*VALUE*}

## DESCRIPTION

Sets the concurrency setting for a *WORKER* or a param value for the *WORKER*.

## OPTIONS

`-C`, `--config-file` *FILE*
: Loads the configuration file from another file.

`-c`, `--concurrency` *WORKER*`=`*NUM*
: Sets the concurrency for the *WORKER*.

`-p`, `--param` *WORKER*`.`*PARAM*`=`*VALUE*
: Set the param value for the *PARAM* and *WORKER*.

`-h`, `--help`
: Print help information

## FILES

`~/.config/ronin-recon/config.yml`
: The path to the default configuration file for `ronin-recon`.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-config-list](ronin-recon-config-list.1.md) [ronin-recon-config-get](ronin-recon-config-get.1.md) [ronin-recon-config-unset](ronin-recon-config-unset.1.md)
