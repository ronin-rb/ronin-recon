# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon test` [*options*] {`--file` *FILE* \| *NAME*} {`--domain` *DOMAIN* \| `--host` *HOST* \| `--ip` *IP* \| `--ip-range` *CIDR*}

## DESCRIPTION

Loads an individual worker and tests it with an input value..

## ARGUMENTS

*NAME*
  The name of the recon worker to load.

## OPTIONS

`-f`, `--file` *FILE*
  Optionally loads the recon worker from the file.

`-D`, `--debug`
  Enables debugging output.

`-d`, `--domain` *DOMAIN*
  The domain to test the recon worker with.

`-H`, `--host` *HOST*
  The host name to test the recon worker with.

`-I`, `--ip` *IP*
  The IP address to test the recon worker with.

`-R`, `--ip-range` *CIDR*
  The IP range to test the recon worker with.

`-h`, `--help`
  Print help information

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

ronin-recon-workers(1) ronin-recon-run(1)
