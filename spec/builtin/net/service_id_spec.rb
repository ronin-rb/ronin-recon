require 'spec_helper'
require 'ronin/recon/builtin/net/service_id'

RSpec.describe Ronin::Recon::Net::ServiceID do
  describe '#process' do
    context 'when nameserver is running on given port' do
      let(:port) { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 53, service: 'domain') }

      it 'must yield Values::Nameserver' do
        yielded_value = nil

        subject.process(port) do |value|
          yielded_value = value
        end

        expect(yielded_value).to be_kind_of(Ronin::Recon::Values::Nameserver)
        expect(yielded_value.name).to eq(port.host)
      end
    end

    context 'when mailserver is running on given port' do
      let(:port) { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 25, service: 'smtp') }

      it 'must yield Values::Mailserver' do
        yielded_value = nil

        subject.process(port) do |value|
          yielded_value = value
        end

        expect(yielded_value).to be_kind_of(Ronin::Recon::Values::Mailserver)
        expect(yielded_value.name).to eq(port.host)
      end
    end

    context 'when http website is running on given port' do
      let(:port) { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 443, service: 'http') }

      it 'must yield Values::Website with http schema' do
        yielded_value = nil

        subject.process(port) do |value|
          yielded_value = value
        end

        expect(yielded_value).to be_kind_of(Ronin::Recon::Values::Website)
        expect(yielded_value.scheme).to eq(:http)
        expect(yielded_value.host).to eq(port.host)
      end

      context 'but it also has ssl enabled' do
        let(:port) { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 80, service: 'http', ssl: true) }

        it 'must yield Values::Website with https schema' do
          yielded_value = nil

          subject.process(port) do |value|
            yielded_value = value
          end

          expect(yielded_value).to be_kind_of(Ronin::Recon::Values::Website)
          expect(yielded_value.scheme).to eq(:https)
          expect(yielded_value.host).to eq(port.host)
        end
      end
    end

    context 'when https website is running on given port' do
      let(:port) { Ronin::Recon::Values::OpenPort.new("93.184.216.34", 443, service: 'https', ssl: true) }

      it 'must yield Values::Website' do
        yielded_value = nil

        subject.process(port) do |value|
          yielded_value = value
        end

        expect(yielded_value).to be_kind_of(Ronin::Recon::Values::Website)
        expect(yielded_value.scheme).to eq(:https)
        expect(yielded_value.host).to eq(port.host)
      end
    end
  end
end
