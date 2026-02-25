FactoryBot.define do
  factory :facility do
    sequence(:name) { |n| "Facility #{n}" }
    sender_email { Faker::Internet.email }
    sender_domain { Faker::Internet.domain_name }
    email_signature { "Best regards,\nFacility Staff" }
  end
end
