FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { "password123" }
    role { User::STAFF_ROLE }

    trait :admin do
      role { User::ADMIN_ROLE }
    end

    trait :staff do
      role { User::STAFF_ROLE }
    end
  end
end
