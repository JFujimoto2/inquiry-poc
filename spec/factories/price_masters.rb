FactoryBot.define do
  factory :price_master do
    facility
    item_type { "conference_room" }
    day_type { "weekday" }
    unit_price { 5000 }
  end
end
