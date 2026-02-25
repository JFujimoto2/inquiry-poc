FactoryBot.define do
  factory :email_template do
    facility
    template_type { "quote" }
    subject { "Quote for {{company_name}}" }
    body { "Dear {{contact_name}},\n\nPlease find your quote attached.\n\nBest regards,\n{{facility_name}}" }

    trait :reservation_confirmation do
      template_type { "reservation_confirmation" }
      subject { "Reservation Confirmed - {{facility_name}}" }
      body { "Dear {{contact_name}},\n\nYour reservation at {{facility_name}} has been confirmed." }
    end
  end
end
