FactoryBot.define do
  factory :task do
    association :project
    association :author, factory: :user
    sequence(:title) { |n| "Task #{n}" }
    status { "todo" }
    priority { "normal" }

    trait :done do
      status { "done" }
      completed_at { 1.hour.ago }
    end

    trait :overdue do
      due_on { 3.days.ago.to_date }
    end

    trait :assigned do
      association :assignee, factory: :user

      after(:build) do |task|
        task.project.memberships.build(user: task.assignee, role: "member")
      end
    end
  end
end
