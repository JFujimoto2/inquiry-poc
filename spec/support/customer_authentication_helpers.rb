module CustomerAuthenticationHelpers
  def sign_in_as_customer(customer)
    token = SecureRandom.urlsafe_base64(32)
    token_digest = Digest::SHA256.hexdigest(token)
    session = customer.customer_sessions.create!(
      token_digest:,
      expires_at: CustomerSession::SESSION_EXPIRY.from_now
    )
    get verify_mypage_session_path(token:)
  end
end

RSpec.configure do |config|
  config.include CustomerAuthenticationHelpers, type: :request
end
