FactoryBot.define do
  factory :inquiry do
    facility
    desired_date { Date.new(2026, 4, 1) }
    desired_end_date { Date.new(2026, 4, 2) }
    num_people { 10 }
    conference_room { true }
    accommodation { false }
    breakfast { false }
    lunch { true }
    dinner { false }
    company_name { Faker::Company.name }
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    total_amount { nil }
  end
end
