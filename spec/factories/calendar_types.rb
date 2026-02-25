FactoryBot.define do
  factory :calendar_type do
    sequence(:date) { |n| Date.new(2026, 1, 1) + n.days }
    day_type { "weekday" }

    trait :holiday do
      day_type { "holiday" }
    end

    trait :day_before_holiday do
      day_type { "day_before_holiday" }
    end
  end
end
