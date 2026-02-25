require "rails_helper"

RSpec.describe Aipass do
  after { described_class.reset! }

  describe ".client" do
    it "returns MockClient in test environment" do
      expect(described_class.client).to be_a(Aipass::MockClient)
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(Aipass::Configuration)
    end
  end

  describe ".configure" do
    it "yields configuration for customization" do
      described_class.configure do |config|
        config.api_key = "test-key"
      end
      expect(described_class.configuration.api_key).to eq("test-key")
    end
  end
end
