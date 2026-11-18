class OverdueReminderJob < ApplicationJob
  queue_as :mailers

  def perform(reference_date = Date.current)
    overdue = Task.open
      .unarchived
      .where(due_on: ...reference_date)
      .where.not(assignee_id: nil)
      .includes(:project, :assignee)

    overdue.group_by(&:assignee).each do |assignee, tasks|
      next unless assignee.email_notifications?

      TaskMailer.with(recipient: assignee, tasks: tasks.sort_by(&:due_on)).overdue_digest.deliver_later
    end
  end
end
