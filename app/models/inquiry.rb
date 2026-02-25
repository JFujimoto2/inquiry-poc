class Inquiry < ApplicationRecord
  belongs_to :facility
  has_one :quote, dependent: :destroy

  validates :desired_date, presence: true
  validates :num_people, presence: true, numericality: { greater_than: 0 }
  validates :company_name, presence: true
  validates :contact_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :breakfast_requires_accommodation

  private

  def breakfast_requires_accommodation
    if breakfast? && !accommodation?
      errors.add(:breakfast, "requires accommodation to be selected")
    end
  end
end
