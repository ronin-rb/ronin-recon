# ronin-recon

[![CI](https://github.com/ronin-rb/ronin-recon/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-recon/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-recon.svg)](https://codeclimate.com/github/ronin-rb/ronin-recon)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-recon)
* [Issues](https://github.com/ronin-rb/ronin-recon/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-recon)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-recon is a micro-framework and tool for performing reconnaissance.
ronin-recon uses multiple workers which process different value types
(ex: IP, host, URL, etc) and produce new values. ronin-recon contains built-in
recon workers and supports loading additional 3rd-party workers from Ruby
files or 3rd-party git repositories. ronin-recon has a unique queue design
and uses asynchronous I/O to maximize efficiency.

## Features

* Uses asynchronous I/O and fibers.
* Supports defining recon modules as plain old Ruby class.
* Provides built-in recon workers for:
  * IP range enumeration.
  * DNS lookup of host-names.
  * Querying nameservers.
  * Querying mailservers.
  * DNS reverse lookup of IP addresses.
  * DNS SRV record enumeration.
  * DNS subdomain enumeration.
  * Service/port scanning with `nmap`.
  * Enumerates the Common Name (`CN`) and `subjectAltName`s within all SSL/TLS
    certificates.
  * Web spidering.
  * HTTP directory enumeration.
* Supports loading additional recon modules from Ruby files or from installed
  [3rd-party git repositories][ronin-repos].
* Builds a network graph of all discovered assets.
* Provides a simple CLI for listing workers or performing recon.
* Supports many different output file formats:
  * TXT
  * CSV
  * JSON
  * [NDJSON](http://ndjson.org/)
  * [GraphViz DOT](https://graphviz.org/doc/info/lang.html)
* Supports automatically saving recon results into [ronin-db].

## Anti-Features

* Does not require API keys to run.
* Not just a script that runs a bunch of other recon tools.

## Synopsis

```
$ ronin-recon
Usage: ronin-recon [options]

Options:
    -V, --version                    Prints the version and exits
    -h, --help                       Print help information

Arguments:
    [COMMAND]                        The command name to run
    [ARGS ...]                       Additional arguments for the command

Commands:
    help
    run
    test
    worker
    workers
```

List all available recon workers:

```shell
$ ronin-recon workers
  dns/lookup
  dns/mailservers
  dns/nameservers
  dns/srv_enum
  dns/subdomain_enum
  dns/suffix_enum
  net/cert_enum
  net/cert_grab
  net/ip_range_enum
  net/service_scan
  web/dir_enum
  web/spider
```

Print info about a specific recon worker:

```shell
$ ronin-recon worker dns/lookup
[ dns/lookup ]

  Summary: Looks up the IPs of a host-name
  Description:

    Resolves the IP addresses of domains, host names, nameservers,
    and mailservers.

  Accepts:

    * domains
    * hosts
    * nameservers
    * mailservers

```

Run the recon engine on a single domain:

```shell
$ ronin-recon run example.com
```

Run the recon engine on a single host-name:

```shell
$ ronin-recon run www.example.com
```

Run the recon engine on a single IP address:

```shell
$ ronin-recon run 1.1.1.1
```

Run the recon engine on an IP range:

```shell
$ ronin-recon run 1.1.1.1/24
```

Run the recon engine on multiple targets:

```shell
$ ronin-recon run example1.com example2.com secret.foo.example1.com secret.bar.example2.com 1.1.1.1/24
```

Run the recon engine and ignore values from result:

```shell
$ ronin-recon run -I www.example.com example.com
```

## Examples

```ruby
require 'ronin/recon/engine'

domain = Ronin::Recon::Values::Domain.new('github.com')

Ronin::Recon::Engine.run([domain], max_depth: 3) do |value,parent|
  case value
  when Ronin::Recon::Values::Domain
    puts "Found domain #{value} for #{parent}"
  when Ronin::Recon::Values::Nameserver
    puts "Found nameserver #{value} for #{parent}"
  when Ronin::Recon::Values::Mailserver
    puts "Found mailserver #{value} for #{parent}"
  when Ronin::Recon::Values::Host
    puts "Found host #{value} for #{parent}"
  when Ronin::Recon::Values::IP
    puts "Found IP address #{value} for #{parent}"
  end
end
```

## Requirements

* [Ruby] >= 3.0.0
* [nmap] >= 5.00
* [thread-local] ~> 1.0
* [async-io] ~> 1.0
* [async-dns] ~> 1.0
* [async-http] ~> 0.60
* [wordlist] ~> 1.0, >= 1.0.3
* [ronin-support] ~> 1.0
* [ronin-core] ~> 0.1
* [ronin-db] ~> 0.2
* [ronin-repos] ~> 0.1
* [ronin-masscan] ~> 0.1
* [ronin-nmap] ~> 0.1
* [ronin-web-spider] ~> 0.2

## Install

```shell
$ gem install ronin-recon
```

### Gemfile

```ruby
gem 'ronin-recon', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-recon', '~> 0.1'
```

## Post-Install

### Running `nmap` / `masscan` without `sudo`

You can configure `nmap` and `masscan` to run without `sudo` by setting their
capabilities:

```shell
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip $(which nmap)
sudo setcap cap_net_raw,cap_net_admin,cap_net_bind_service+eip $(which masscan)
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-recon/fork)
2. Clone It!
3. `cd ronin-recon/`
4. `bundle install`
5. `rake wordlists` (generates the built-in wordlists)
6. `git checkout -b my_feature`
7. Code It!
8. `bundle exec rake spec`
9. `git push origin my_feature`

## License

ronin-recon - A micro-framework and tool for performing reconnaissance.

Copyright (c) 2023 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-recon is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-recon is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-recon.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[nmap]: http://www.insecure.org/
[thread-local]: https://github.com/socketry/thread-local#readme
[async-io]: https://github.com/socketry/async-io#readme
[async-dns]: https://github.com/socketry/async-dns#readme
[async-http]: https://github.com/socketry/async-http#readme
[wordlist]: https://github.com/postmodern/wordlist.rb#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
[ronin-core]: https://github.com/ronin-rb/ronin-core#readme
[ronin-db]: https://github.com/ronin-rb/ronin-db#readme
[ronin-repos]: https://github.com/ronin-rb/ronin-repos#readme
[ronin-masscan]: https://github.com/ronin-rb/ronin-masscan#readme
[ronin-nmap]: https://github.com/ronin-rb/ronin-nmap#readme
[ronin-web-spider]: https://github.com/ronin-rb/ronin-web-spider#readme
