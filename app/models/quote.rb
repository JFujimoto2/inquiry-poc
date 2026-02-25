class Quote < ApplicationRecord
  STATUSES = %w[pending generated sent failed].freeze

  belongs_to :inquiry

  validates :status, presence: true, inclusion: { in: STATUSES }
end
