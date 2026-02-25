module Aipass
  class Configuration
    DEFAULT_TIMEOUT = 30

    attr_accessor :base_url, :api_key, :timeout

    def initialize
      @base_url = ENV.fetch("AIPASS_BASE_URL", "https://api.aipass.example.com")
      @api_key = ENV.fetch("AIPASS_API_KEY", nil)
      @timeout = ENV.fetch("AIPASS_TIMEOUT", DEFAULT_TIMEOUT).to_i
    end

    def configured?
      base_url.present? && api_key.present?
    end
  end
end
