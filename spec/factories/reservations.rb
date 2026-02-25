FactoryBot.define do
  factory :reservation do
    inquiry
    customer
    facility
    status { "pending_confirmation" }
    check_in_date { Date.new(2026, 4, 1) }
    check_out_date { Date.new(2026, 4, 2) }
    num_people { 10 }
    total_amount { 50_000 }

    trait :confirmed do
      status { "confirmed" }
      confirmed_at { Time.current }
    end

    trait :checked_in do
      status { "checked_in" }
      confirmed_at { Time.current }
    end

    trait :checked_out do
      status { "checked_out" }
      confirmed_at { Time.current }
    end

    trait :cancelled do
      status { "cancelled" }
      cancelled_at { Time.current }
    end
  end
end
