# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon run` [*options*] {`--domain` *DOMAIN* \| `--host` *HOST* \| `--ip` *IP* \| `--ip-range` *CIDR*}

## DESCRIPTION

Runs the recon engine with one or more initial values.

## OPTIONS

`-D`, `--debug`
  Enables debugging output.

`--max-depth` *NUM*
  The maximum recon depth. Defaults to depth of `1` if the option is not
  specified.

`-d`, `--domain` *DOMAIN*
  The domain to start reconning.

`-H`, `--host` *HOST*
  The host name to start reconning.

`-I`, `--ip` *IP*
  The IP address to start reconning.

`-R`, `--ip-range` *CIDR*
  The IP range to start reconning.

`-h`, `--help`
  Print help information

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

ronin-recon-workers(1) ronin-recon-worker(1) ronin-recon-test(1)
