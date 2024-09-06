require 'spec_helper'
require 'ronin/recon/cli/commands/workers'
require 'ronin/recon/config'

describe Ronin::Recon::CLI::Commands::Workers do
  describe "#run" do
    let(:config) { Ronin::Recon::Config.default }

    it "must list all worker IDs" do
      expect {
        subject.run
      }.to output(
        [
          "  api/built_with                    ",
          "  api/crt_sh                        ",
          "  api/hunter_io                     ",
          "  api/security_trails               ",
          "  api/zoom_eye                      ",
          "  dns/lookup             [enabled]  ",
          "  dns/mailservers        [enabled]  ",
          "  dns/nameservers        [enabled]  ",
          "  dns/reverse_lookup     [enabled]  ",
          "  dns/srv_enum           [enabled]  ",
          "  dns/subdomain_enum     [enabled]  ",
          "  dns/suffix_enum        [enabled]  ",
          "  net/ip_range_enum      [enabled]  ",
          "  net/port_scan          [enabled]  ",
          "  net/service_id         [enabled]  ",
          "  ssl/cert_enum          [enabled]  ",
          "  ssl/cert_grab          [enabled]  ",
          "  web/dir_enum           [enabled]  ",
          "  web/email_addresses    [enabled]  ",
          "  web/screenshot                    ",
          "  web/spider             [enabled]  ",
          ""
        ].join($/)
      ).to_stdout
    end

    context "when given a directory argument" do
      let(:dir) { 'dns' }

      it "must only list workers that exist within that directory" do
        expect {
          subject.run(dir)
        }.to output(
          [
            "  dns/lookup            [enabled]  ",
            "  dns/mailservers       [enabled]  ",
            "  dns/nameservers       [enabled]  ",
            "  dns/reverse_lookup    [enabled]  ",
            "  dns/srv_enum          [enabled]  ",
            "  dns/subdomain_enum    [enabled]  ",
            "  dns/suffix_enum       [enabled]  ",
            ""
          ].join($/)
        ).to_stdout
      end
    end
  end
end
