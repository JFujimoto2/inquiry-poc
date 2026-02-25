class EmailTemplate < ApplicationRecord
  TEMPLATE_TYPES = %w[quote reservation_confirmation].freeze

  belongs_to :facility

  validates :subject, presence: true
  validates :body, presence: true
  validates :template_type, presence: true, inclusion: { in: TEMPLATE_TYPES }
  validates :template_type, uniqueness: { scope: :facility_id }
end
