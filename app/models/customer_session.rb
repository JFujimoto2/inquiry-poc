class CustomerSession < ApplicationRecord
  MAGIC_LINK_EXPIRY = 30.minutes
  SESSION_EXPIRY = 30.days

  belongs_to :customer

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, -> { where("expires_at > ?", Time.current) }

  def expired?
    expires_at <= Time.current
  end
end
