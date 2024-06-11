require 'spec_helper'
require 'ronin/recon/cli/commands/workers'

describe Ronin::Recon::CLI::Commands::Workers do
  describe "#run" do
    it "must list all worker IDs" do
      expect {
        subject.run
      }.to output(
        [
          '  dns/lookup',
          '  dns/mailservers',
          '  dns/nameservers',
          '  dns/reverse_lookup',
          '  dns/srv_enum',
          '  dns/subdomain_enum',
          '  dns/suffix_enum',
          '  net/ip_range_enum',
          '  net/port_scan',
          '  net/service_id',
          '  ssl/cert_enum',
          '  ssl/cert_grab',
          '  ssl/cert_sh',
          '  web/dir_enum',
          '  web/email_addresses',
          '  web/spider',
          ''
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
            '  dns/lookup',
            '  dns/mailservers',
            '  dns/nameservers',
            '  dns/reverse_lookup',
            '  dns/srv_enum',
            '  dns/subdomain_enum',
            '  dns/suffix_enum',
            ''
          ].join($/)
        ).to_stdout
      end
    end
  end
end
