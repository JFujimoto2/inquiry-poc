require "rails_helper"

RSpec.describe Aipass::Configuration do
  describe "defaults" do
    it "reads base_url from ENV with default" do
      config = described_class.new
      expect(config.base_url).to eq("https://api.aipass.example.com")
    end

    it "reads timeout from ENV with default" do
      config = described_class.new
      expect(config.timeout).to eq(Aipass::Configuration::DEFAULT_TIMEOUT)
    end

    it "reads api_key from ENV" do
      config = described_class.new
      expect(config.api_key).to be_nil
    end
  end

  describe "#configured?" do
    it "returns false when api_key is missing" do
      config = described_class.new
      expect(config.configured?).to be false
    end

    it "returns true when both base_url and api_key are set" do
      config = described_class.new
      config.api_key = "test-key"
      expect(config.configured?).to be true
    end
  end
end
