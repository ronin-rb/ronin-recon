# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon run` [*options*] {`--domain` *DOMAIN* \| `--host` *HOST* \| `--ip` *IP* \| `--ip-range` *CIDR*}

## DESCRIPTION

Runs the recon engine with one or more initial values.

## OPTIONS

`-D`, `--debug`
  Enables debugging output.

`--max-depth` *NUM*
  The maximum recon depth. Defaults to depth of `3` if the option is not
  specified.

`-d`, `--domain` *DOMAIN*
  The domain to start reconning.

`-H`, `--host` *HOST*
  The host name to start reconning.

`-I`, `--ip` *IP*
  The IP address to start reconning.

`-R`, `--ip-range` *CIDR*
  The IP range to start reconning.

`-o`, `--output` *FILE*
  The output file to write results to.

`-F`, `--output-format` `txt`\|`list`\|`csv`\|`json`\|`ndjson`\|`dot`
  The output format. If not specified, the output format will be inferred from
  the `--output` *FILE* extension.

`--import`
  Imports each newly discovered value into the Ronin database.

`-h`, `--help`
  Print help information

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

ronin-recon-workers(1) ronin-recon-worker(1) ronin-recon-test(1)
