return unless Rails.env.development?

alice = User.find_or_create_by!(email: "alice@tracker.example") do |user|
  user.name = "Alice Example"
  user.password = "password"
  user.time_zone = "Europe/Berlin"
end

bob = User.find_or_create_by!(email: "bob@tracker.example") do |user|
  user.name = "Bob Example"
  user.password = "password"
  user.time_zone = "UTC"
end

project = Project.find_or_create_by!(identifier: "website") do |record|
  record.name = "Website Relaunch"
  record.budget_cents = 2_500_000
end

project.memberships.find_or_create_by!(user: alice) { |membership| membership.role = "owner" }
project.memberships.find_or_create_by!(user: bob) { |membership| membership.role = "member" }

[
  { title: "Set up CI pipeline", status: "done", priority: "high" },
  { title: "Design landing page", status: "in_progress", priority: "normal", assignee: bob },
  { title: "Write copy for pricing page", status: "todo", priority: "low", due_on: 1.week.from_now },
  { title: "Fix broken signup flow", status: "review", priority: "urgent", assignee: alice, due_on: 2.days.ago },
].each do |attributes|
  project.tasks.find_or_create_by!(title: attributes[:title]) do |task|
    task.assign_attributes(attributes.except(:title).merge(author: alice))
  end
end

puts "Seeded #{User.count} users, #{Project.count} projects and #{Task.count} tasks"
