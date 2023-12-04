# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon run` [*options*] {*IP* \| *IP-range* \| *DOMAIN* \| *HOST* \| *WILDCARD* \| *WEBSITE*} ... 

## DESCRIPTION

Runs the recon engine with one or more initial values.

## ARGUMENTS

*IP*
: An IP address to recon (ex: `192.168.1.1`).

*IP-range*
: A CIDR IP range to recon (ex: `192.168.1.0/24`).

*DOMAIN*
: A top-level domain name to recon (ex: `example.com`).

*HOST*
: A sub-domain to recon (ex: `www.example.com`).

*WILDCARD*
: A wildcard host name (ex: `*.example.com`).

*WEBSITE*
: A website base URL to recon (ex: `https://example.com`).

## OPTIONS

`-D`, `--debug`
: Enables debugging output.

`--max-depth` *NUM*
: The maximum recon depth. Defaults to depth of `3` if the option is not
  specified.

`-o`, `--output` *FILE*
: The output file to write results to.

`-F`, `--output-format` `txt`\|`list`\|`csv`\|`json`\|`ndjson`\|`dot`\|`svg`\|`png`\|`pdf`
: The output format. If not specified, the output format will be inferred from
  the `--output` *FILE* extension.

`--import`
: Imports each newly discovered value into the Ronin database.

`-I`, `--ignore` *VALUE*
: The value to ignore from the result.

`-h`, `--help`
: Print help information

## EXAMPLES

Run the recon engine on a single domain:

    $ ronin-recon run example.com

Run the recon engine on a single host-name:

    $ ronin-recon run www.example.com

Run the recon engine on a single IP address:

    $ ronin-recon run 1.1.1.1

Run the recon engine on an IP range:

    $ ronin-recon run 1.1.1.1/24

Run the recon engine on multiple targets:

    $ ronin-recon run example1.com example2.com secret.foo.example1.com \
                      secret.bar.example2.com 1.1.1.1/24

Run the recon engine and ignore specific hosts, IPs, URLs, etc.:

    $ ronin-recon run --ignore staging.example.com example.com

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-workers](ronin-recon-workers.1.md) [ronin-recon-worker](ronin-recon-worker.1.md) [ronin-recon-test](ronin-recon-test.1.md)
