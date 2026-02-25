class CalendarType < ApplicationRecord
  DAY_TYPES = %w[weekday holiday day_before_holiday].freeze

  validates :date, presence: true, uniqueness: true
  validates :day_type, presence: true, inclusion: { in: DAY_TYPES }

  def self.day_type_for(date)
    find_by(date: date)&.day_type || "weekday"
  end
end
