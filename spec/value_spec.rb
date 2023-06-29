require 'spec_helper'
require 'ronin/recon/value'

describe Ronin::Recon::Value do
  describe ".value_type" do
    subject { described_class }

    it do
      expect {
        subject.value_type
      }.to raise_error(NotImplementedError,"#{described_class}.value_type was not defined")
    end
  end

  describe "#as_json" do
    subject { described_class.new }

    it do
      expect {
        subject.as_json
      }.to raise_error(NotImplementedError,"#{described_class}#as_json was not implemented")
    end
  end

  describe "#to_s" do
    subject { described_class.new }

    it do
      expect {
        subject.to_s
      }.to raise_error(NotImplementedError,"#{described_class}#to_s was not implemented")
    end
  end

  module TestValue
    class TestValue < Ronin::Recon::Value
      attr_reader :a, :b

      def initialize
        @a = 1
        @b = 2
      end

      def eql?(other)
        self.class == other.class &&
          @a == other.a &&
          @b == other.b
      end

      def as_json
        {
          type: :test,
          a:    @a,
          b:    @b
        }
      end

      def to_s
        "test"
      end

      def self.value_type
        :test
      end
    end
  end

  let(:value_class) { TestValue::TestValue }
  subject { value_class.new }

  describe "#==" do
    it "must call #eql?" do
      expect(subject == value_class.new).to be(true)
    end
  end

  describe "#to_json" do
    it "must call #as_json and convert it to JSON" do
      expect(subject.to_json).to eq(subject.as_json.to_json)
    end
  end

  describe "#to_csv" do
    it "must return the .value_type with the #to_s value as two CSV columns" do
      expect(subject.to_csv).to eq("#{value_class.value_type},#{subject}\n")
    end
  end
end
