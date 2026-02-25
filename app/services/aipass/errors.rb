module Aipass
  class Error < StandardError; end
  class ConnectionError < Error; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end
  class RateLimitError < Error; end
  class ServerError < Error; end
end
