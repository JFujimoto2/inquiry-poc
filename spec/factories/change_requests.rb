FactoryBot.define do
  factory :change_request do
    reservation
    customer
    request_details { "I would like to change the check-in date." }
    status { "pending" }

    trait :approved do
      status { "approved" }
      admin_response { "Your request has been approved." }
    end

    trait :rejected do
      status { "rejected" }
      admin_response { "Unfortunately, we cannot accommodate this change." }
    end
  end
end
