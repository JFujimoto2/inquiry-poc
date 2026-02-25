class Customer < ApplicationRecord
  has_many :inquiries, dependent: :nullify
  has_many :reservations, dependent: :destroy
  has_many :customer_sessions, dependent: :destroy
  has_many :change_requests, dependent: :destroy

  validates :company_name, presence: true
  validates :contact_name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.strip.downcase }
end
