class CustomerMagicLinkSender
  def initialize(customer)
    @customer = customer
  end

  def call
    token = SecureRandom.urlsafe_base64(32)
    token_digest = Digest::SHA256.hexdigest(token)

    @customer.customer_sessions.create!(
      token_digest:,
      expires_at: CustomerSession::MAGIC_LINK_EXPIRY.from_now
    )

    CustomerMailer.magic_link(@customer, token).deliver_later
    token
  end
end
