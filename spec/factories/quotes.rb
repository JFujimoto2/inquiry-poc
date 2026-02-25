FactoryBot.define do
  factory :quote do
    inquiry
    status { Quote::STATUS_PENDING }
    pdf_data { nil }
    sent_at { nil }

    trait :generated do
      status { Quote::STATUS_GENERATED }
      pdf_data { "%PDF-1.4 test" }
    end

    trait :sent do
      status { Quote::STATUS_SENT }
      pdf_data { "%PDF-1.4 test" }
      sent_at { Time.current }
    end

    trait :failed do
      status { Quote::STATUS_FAILED }
    end
  end
end
