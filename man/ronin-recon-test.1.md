# ronin-recon-test 1 "2023-05-01" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon test` [*options*] {`--file` *FILE* \| *NAME*} {*IP* \| *IP-range* \| *DOMAIN* \| *HOST* \| *WILDCARD* \| *WEBSITE*}

## DESCRIPTION

Loads an individual worker and tests it with an input value..

## ARGUMENTS

*NAME*
: The name of the recon worker to load.

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

`-f`, `--file` *FILE*
: Optionally loads the recon worker from the file.

`-D`, `--debug`
: Enables debugging output.

`-h`, `--help`
: Print help information

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-workers](ronin-recon-workers.1.md) [ronin-recon-run](ronin-recon-run.1.md)