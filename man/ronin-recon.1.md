# ronin-recon 1 "2024-01-01" Ronin Recon "User Manuals"

## NAME

ronin-recon - A micro-framework and tool for performing reconnaissance.

## SYNOPSIS

`ronin-recon` [*options*] [*COMMAND* [...]]

## DESCRIPTION

Runs a `ronin-recon` *COMMAND*.

## ARGUMENTS

*COMMAND*
: The `ronin-recon` command to execute.

## OPTIONS

`-V`, `--version`
: Prints the `ronin-recon` version and exits.

`-h`, `--help`
: Print help information

## COMMANDS

*completion*
: Manages the shell completion rules for `ronin-recon`.

*help*
: Lists available commands or shows help about a specific command.

*irb*
: Starts an interactive Ruby shell with ronin-recon loaded.

*new*
: Creates a new recon worker file.

*run*
: Runs the recon engine with one or more initial values.

*run-worker*, *test*
: Loads an individual worker and runs it.

*worker*
: Prints information about a recon worker.

*workers*
: Lists the available recon workers.

## AUTHOR

Postmodern <postmodern.mod3@gmail.com>

## SEE ALSO

[ronin-recon-completion](ronin-recon-completion.1.md) [ronin-recon-new](ronin-recon-new.1.md) [ronin-recon-test](ronin-recon-test.1.md) [ronin-recon-worker](ronin-recon-worker.1.md) [ronin-recon-workers](ronin-recon-workers.1.md)
