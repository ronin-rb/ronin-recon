require 'spec_helper'
require 'ronin/recon/builtin/net/ip_range_enum'

describe Ronin::Recon::Net::IPRangeEnum do
  describe "#process" do
    context "when there are ip in range" do
      let(:ip_range) { Ronin::Recon::Values::IPRange.new('192.168.0.1/2') }

      it "must yield IP values" do
        yielded_values = []

        subject.process(ip_range) do |value|
          yielded_values << value
        end
      end
    end

    context "when there is no ip in range" do
      let(:ip_range) { Ronin::Recon::Values::IPRange.new('192.168.0.1/2') }

      it "must not yield anything" do
        expect { |b|
          subject.process(ip_range,&b)
        }.to_not yield_control
      end
    end
  end
end
