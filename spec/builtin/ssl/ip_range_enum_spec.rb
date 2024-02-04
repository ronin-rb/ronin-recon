require 'spec_helper'
require 'ronin/recon/builtin/net/ip_range_enum'

describe Ronin::Recon::Net::IPRangeEnum do
  describe "#process" do
    context "when there are ips within the range" do
      let(:ip_range) { Ronin::Recon::Values::IPRange.new('192.168.0.1/30') }
      let(:addresses) do
        [
          "192.168.0.0",
          "192.168.0.1",
          "192.168.0.2",
          "192.168.0.3"
        ]
      end

      it "must yield each value" do
        yielded_values = []

        subject.process(ip_range) do |value|
          yielded_values << value
        end

        expect(yielded_values).to_not be_empty
        expect(yielded_values).to all(be_kind_of(Ronin::Recon::Values::IP))
        expect(yielded_values.map(&:address)).to match_array(addresses)
      end
    end
  end
end
