FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:identifier) { |n| "project-#{n}" }

    transient do
      owner { nil }
      members { [] }
    end

    after(:create) do |project, evaluator|
      project.memberships.create!(user: evaluator.owner, role: "owner") if evaluator.owner
      evaluator.members.each { |member| project.memberships.create!(user: member, role: "member") }
    end

    trait :archived do
      archived_at { 1.day.ago }
    end

    trait :with_budget do
      budget_cents { 1_000_000 }
      hourly_rate_cents { 10_000 }
    end
  end
end
