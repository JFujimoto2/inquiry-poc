class Quote < ApplicationRecord
  STATUS_PENDING = "pending"
  STATUS_GENERATED = "generated"
  STATUS_SENT = "sent"
  STATUS_FAILED = "failed"
  STATUSES = [ STATUS_PENDING, STATUS_GENERATED, STATUS_SENT, STATUS_FAILED ].freeze

  belongs_to :inquiry

  validates :status, presence: true, inclusion: { in: STATUSES }
end
