module TasksHelper
  STATUS_COLORS = {
    "todo"        => "secondary",
    "in_progress" => "primary",
    "review"      => "warning",
    "done"        => "success",
  }.freeze

  def task_status_badge(task)
    tag.span(
      Task.human_attribute_name("status.#{task.status}"),
      class: ["badge", "bg-#{STATUS_COLORS.fetch(task.status)}"]
    )
  end

  def task_due_label(task)
    return if task.due_on.blank?

    if task.overdue?
      tag.span(t("tasks.due.overdue", days: (Date.current - task.due_on).to_i), class: "text-danger")
    elsif task.due_on.today?
      t("tasks.due.today")
    else
      t("tasks.due.on", date: l(task.due_on, format: :short))
    end
  end

  def priority_icon(task)
    icon = case task.priority
           when "urgent" then "alert-triangle"
           when "high" then "arrow-up"
           when "low" then "arrow-down"
           end

    tag.i(class: "ti ti-#{icon}", title: task.priority.humanize) if icon
  end
end
