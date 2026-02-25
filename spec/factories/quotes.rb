FactoryBot.define do
  factory :quote do
    inquiry
    status { "pending" }
    pdf_data { nil }
    sent_at { nil }

    trait :generated do
      status { "generated" }
      pdf_data { "%PDF-1.4 test" }
    end

    trait :sent do
      status { "sent" }
      pdf_data { "%PDF-1.4 test" }
      sent_at { Time.current }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
