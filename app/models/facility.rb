class Facility < ApplicationRecord
  has_many :price_masters, dependent: :destroy
  has_one :email_template, dependent: :destroy
  has_many :inquiries, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :sender_email, presence: true
  validates :sender_domain, presence: true
end
