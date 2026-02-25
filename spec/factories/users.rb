FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { "password123" }
    role { "staff" }

    trait :admin do
      role { "admin" }
    end

    trait :staff do
      role { "staff" }
    end
  end
end
