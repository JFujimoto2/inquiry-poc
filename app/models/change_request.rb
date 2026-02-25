class ChangeRequest < ApplicationRecord
  STATUSES = %w[pending approved rejected].freeze

  belongs_to :reservation
  belongs_to :customer

  validates :request_details, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
end
