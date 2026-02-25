class PriceMaster < ApplicationRecord
  ITEM_TYPES = %w[conference_room accommodation breakfast lunch dinner].freeze
  DAY_TYPES = CalendarType::DAY_TYPES

  belongs_to :facility

  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :day_type, presence: true, inclusion: { in: DAY_TYPES }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :item_type, uniqueness: { scope: [ :facility_id, :day_type ] }

  def self.price_for(facility, item_type, day_type)
    find_by!(facility: facility, item_type: item_type, day_type: day_type).unit_price
  end
end
