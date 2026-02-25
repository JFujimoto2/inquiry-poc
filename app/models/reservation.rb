class Reservation < ApplicationRecord
  STATUS_PENDING_CONFIRMATION = "pending_confirmation"
  STATUS_CONFIRMED = "confirmed"
  STATUS_CHECKED_IN = "checked_in"
  STATUS_CHECKED_OUT = "checked_out"
  STATUS_CANCELLED = "cancelled"
  STATUSES = [
    STATUS_PENDING_CONFIRMATION, STATUS_CONFIRMED, STATUS_CHECKED_IN,
    STATUS_CHECKED_OUT, STATUS_CANCELLED
  ].freeze

  belongs_to :inquiry
  belongs_to :customer
  belongs_to :facility
  has_many :change_requests, dependent: :destroy

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :check_in_date, presence: true
  validates :num_people, presence: true, numericality: { greater_than: 0 }
  validate :check_out_after_check_in

  scope :active, -> { where.not(status: STATUS_CANCELLED) }
  scope :upcoming, -> { active.where("check_in_date >= ?", Date.current) }

  private

  def check_out_after_check_in
    return if check_in_date.blank? || check_out_date.blank?

    if check_out_date <= check_in_date
      errors.add(:check_out_date, "must be after check-in date")
    end
  end
end
