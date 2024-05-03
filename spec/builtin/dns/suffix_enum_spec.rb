require 'spec_helper'
require 'ronin/recon/builtin/dns/suffix_enum'

RSpec.describe Ronin::Recon::DNS::SuffixEnum do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe '#process', :network do
    let(:suffix_list) { Ronin::Support::Network::PublicSuffix::List.load_file(suffix_path) }

    before do
      allow(Ronin::Support::Network::PublicSuffix).to receive(:list).and_return(suffix_list)
    end

    context 'when there is a domain with a different suffix' do
      let(:domain)      { Ronin::Recon::Values::Domain.new('example.com') }
      let(:suffix_path) { File.join(fixtures_dir,'public_domains.dat') }
      let(:domains_names) do
        [
          "example.com.zm",
          "example.org.za",
          "example.in.th",
          "example.vn"
        ]
      end

      it 'must yield Values::Domain for each found' do
        yielded_values = []

        subject.process(domain) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::Domain))
        expect(yielded_values.map(&:name)).to match_array(domains_names)
      end
    end

    context 'when there is no domain with a different suffix' do
      let(:domain)      { Ronin::Recon::Values::Domain.new('no_suffixes.com') }
      let(:suffix_path) { File.join(fixtures_dir,'no_suffixes.dat') }

      it 'must not yield anything' do
        expect { |b|
          subject.process(domain, &b)
        }.not_to yield_control
      end
    end
  end
end
