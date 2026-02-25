FactoryBot.define do
  factory :change_request do
    reservation
    customer
    request_details { "I would like to change the check-in date." }
    status { ChangeRequest::STATUS_PENDING }

    trait :approved do
      status { ChangeRequest::STATUS_APPROVED }
      admin_response { "Your request has been approved." }
    end

    trait :rejected do
      status { ChangeRequest::STATUS_REJECTED }
      admin_response { "Unfortunately, we cannot accommodate this change." }
    end
  end
end
