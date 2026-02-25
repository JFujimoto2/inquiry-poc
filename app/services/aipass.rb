module Aipass
  class Error < StandardError; end
  class ConnectionError < Error; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end
  class RateLimitError < Error; end
  class ServerError < Error; end

  class << self
    def client
      @client ||= build_client
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset!
      @client = nil
      @configuration = nil
    end

    private

    def build_client
      if Rails.env.production? && configuration.configured?
        Client.new
      else
        MockClient.new
      end
    end
  end
end
