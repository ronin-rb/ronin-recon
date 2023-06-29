# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon run` [*options*] {*IP* \| *IP-range* \| *DOMAIN* \| *HOST* \| *WILDCARD* \| *WEBSITE*} ... 

## DESCRIPTION

Runs the recon engine with one or more initial values.

## ARGUMENTS

*IP*
  An IP address to recon (ex: `192.168.1.1`).

*IP-range*
  A CIDR IP range to recon (ex: `192.168.1.0/24`).

*DOMAIN*
  A top-level domain name to recon (ex: `example.com`).

*HOST*
  A sub-domain to recon (ex: `www.example.com`).

*WILDCARD*
  A wildcard host name (ex: `*.example.com`).

*WEBSITE*
  A website base URL to recon (ex: `https://example.com`).

## OPTIONS

`-D`, `--debug`
  Enables debugging output.

`--max-depth` *NUM*
  The maximum recon depth. Defaults to depth of `3` if the option is not
  specified.

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
