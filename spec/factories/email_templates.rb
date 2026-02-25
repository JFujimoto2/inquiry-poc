FactoryBot.define do
  factory :email_template do
    facility
    subject { "Quote for {{company_name}}" }
    body { "Dear {{contact_name}},\n\nPlease find your quote attached.\n\nBest regards,\n{{facility_name}}" }
  end
end
