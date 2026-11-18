module Reports
  class ProjectSummary
    Row = Data.define(:assignee, :open, :done, :overdue, :hours_logged)

    def initialize(project, period: 30.days)
      @project = project
      @period = period
    end

    def call
      {
        progress:        @project.progress,
        open_count:      tasks.open.count,
        completed_count: completed_in_period.count,
        overdue_count:   @project.overdue_tasks.count,
        velocity:        velocity,
        by_assignee:     rows_by_assignee,
        burn_rate:       burn_rate,
      }
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << %w[Assignee Open Done Overdue Hours]
        rows_by_assignee.each do |row|
          csv << [row.assignee&.name || "Unassigned", row.open, row.done, row.overdue, row.hours_logged.round(1)]
        end
      end
    end

    private

    def tasks
      @tasks ||= @project.tasks.unarchived
    end

    def completed_in_period
      tasks.done.where(completed_at: @period.ago..)
    end

    def velocity
      weeks = @period.in_weeks
      return 0 if weeks == 0

      (completed_in_period.count / weeks).round(1)
    end

    def burn_rate
      return if @project.budget_cents.blank?

      hours = tasks.sum(:logged_hours)
      spent_cents = hours * @project.hourly_rate_cents.to_i

      case spent_cents.fdiv(@project.budget_cents)
      when 0...0.5 then :healthy
      when 0.5...0.9 then :watch
      else :critical
      end
    end

    def rows_by_assignee
      @rows_by_assignee ||= tasks.includes(:assignee).group_by(&:assignee).map do |assignee, assigned|
        Row.new(
          assignee:     assignee,
          open:         assigned.count { |task| !task.done? },
          done:         assigned.count(&:done?),
          overdue:      assigned.count(&:overdue?),
          hours_logged: assigned.sum { |task| task.logged_hours.to_f }
        )
      end.sort_by { |row| -row.open }
    end
  end
end
