# ronin-recon-new 1 "May 2022" Ronin "User Manuals"

## SYNOPSIS

`ronin-recon new` [*options*] *PATH*

## DESCRIPTION

Generates a new recon worker file.

## ARGUMENTS

*PATH*
  The path to the new recon worker file to generate.

## OPTIONS

`-t`, `--type` `worker`\|`dns`\|`web`
  The type of recon worker to generate.

`-a`, `--author` *NAME*
  The name of the author. Defaults to the configured git author name or the
  `USERNAME` environment variable.

`-e`, `--author-email` *EMAIL*
  The email address of the author. Defaults to the configured git author email.

`-S`, `--summary` *TEXT*
  The summary text for the new recon worker.

`-D`, `--description` *TEXT*
  The description text for the new recon worker.

`-R`, `--reference` *URL*
  Adds a reference URL to the new recon worker.

`-A`, `--accepts` `cert`\|`domain|email_address|host|ip_range|ip|mailserver|nameserver|open_port|url|website|wildcard`
  The value type(s) that the recon worker accepts.

`-O`, `--outputs` `cert`\|`domain|email_address|host|ip_range|ip|mailserver|nameserver|open_port|url|website|wildcard`
  The value type(s) that the recon worker outputs.

`-I`, `--intensity` `passive`\|`active`\|`intensive`
  The intensity of the recon worker.

`-h`, `--help`
  Print help information

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

ronin-payloads-workers(1) ronin-payloads-worker(1) ronin-payloads-test(1)
