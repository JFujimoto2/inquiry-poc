FactoryBot.define do
  factory :customer_session do
    customer
    token_digest { Digest::SHA256.hexdigest(SecureRandom.urlsafe_base64(32)) }
    expires_at { 30.minutes.from_now }

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
