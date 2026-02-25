FactoryBot.define do
  factory :customer do
    company_name { Faker::Company.name }
    contact_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    notes { nil }
  end
end
