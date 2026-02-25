class Reservation < ApplicationRecord
  STATUSES = %w[pending_confirmation confirmed checked_in checked_out cancelled].freeze

  belongs_to :inquiry
  belongs_to :customer
  belongs_to :facility
  has_many :change_requests, dependent: :destroy

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :check_in_date, presence: true
  validates :num_people, presence: true, numericality: { greater_than: 0 }
  validate :check_out_after_check_in

  scope :active, -> { where.not(status: "cancelled") }
  scope :upcoming, -> { active.where("check_in_date >= ?", Date.current) }

  private

  def check_out_after_check_in
    return if check_in_date.blank? || check_out_date.blank?

    if check_out_date <= check_in_date
      errors.add(:check_out_date, "must be after check-in date")
    end
  end
end
