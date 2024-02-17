require 'spec_helper'
require 'ronin/recon/builtin/dns/reverse_lookup'

describe Ronin::Recon::DNS::ReverseLookup do
  describe "#process", :network do
    context "when there the IP address has a PTR record back to a host name" do
      let(:ip)   { Ronin::Recon::Values::IP.new('1.1.1.1') }
      let(:host) { Ronin::Recon::Values::Host.new('one.one.one.one') }

      it "must yield a Host value" do
        yielded_values = []

        Async do
          subject.process(ip) do |value|
            yielded_values << value
          end
        end

        expect(yielded_values).to eq([host])
      end

      context "but the IP value is already has a #host" do
        let(:ip) do
          Ronin::Recon::Values::IP.new('1.1.1.1', host: 'one.one.one.one')
        end

        it "must not yield any values" do
          expect { |b|
            Async do
              subject.process(ip,&b)
            end
          }.not_to yield_control
        end
      end
    end

    context "but the IP address has no PTR records" do
      let(:ip) { Ronin::Recon::Values::IP.new('93.184.216.34') }

      it "must not yield anything" do
        expect { |b|
          Async do
            subject.process(ip,&b)
          end
        }.not_to yield_control
      end
    end
  end
end
