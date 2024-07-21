### 0.1.0 / 2024-07-22

* Initial release:
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
    * [GraphViz][graphviz]
      * DOT
      * SVG
      * PNG
      * PDF
  * Supports automatically saving recon results into [ronin-db].

[graphviz]: https://graphviz.org/
[ronin-repos]: https://github.com/ronin-rb/ronin-repos#readme
