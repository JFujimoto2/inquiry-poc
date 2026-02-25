class ChangeRequest < ApplicationRecord
  STATUS_PENDING = "pending"
  STATUS_APPROVED = "approved"
  STATUS_REJECTED = "rejected"
  STATUSES = [ STATUS_PENDING, STATUS_APPROVED, STATUS_REJECTED ].freeze

  belongs_to :reservation
  belongs_to :customer

  validates :request_details, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: STATUS_PENDING) }
end
