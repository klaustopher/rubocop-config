FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@tracker.example" }
    name { "Jane Doe" }
    password { "s3cret-password" }
    time_zone { "UTC" }
    email_notifications { true }

    trait :muted do
      email_notifications { false }
    end
  end
end
