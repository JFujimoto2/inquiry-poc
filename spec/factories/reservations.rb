FactoryBot.define do
  factory :reservation do
    inquiry
    customer
    facility
    status { Reservation::STATUS_PENDING_CONFIRMATION }
    check_in_date { Date.new(2026, 4, 1) }
    check_out_date { Date.new(2026, 4, 2) }
    num_people { 10 }
    total_amount { 50_000 }

    trait :confirmed do
      status { Reservation::STATUS_CONFIRMED }
      confirmed_at { Time.current }
    end

    trait :checked_in do
      status { Reservation::STATUS_CHECKED_IN }
      confirmed_at { Time.current }
    end

    trait :checked_out do
      status { Reservation::STATUS_CHECKED_OUT }
      confirmed_at { Time.current }
    end

    trait :cancelled do
      status { Reservation::STATUS_CANCELLED }
      cancelled_at { Time.current }
    end
  end
end
