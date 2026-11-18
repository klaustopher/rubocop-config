module Tasks
  class BulkReassign
    Result = Data.define(:updated_count, :errors) do
      def success?
        errors.empty?
      end
    end

    MAX_TASKS = 200

    def initialize(project:, task_ids:, assignee:, actor:)
      @project = project
      @task_ids = Array(task_ids).compact_blank.map(&:to_i).uniq
      @assignee = assignee
      @actor = actor
    end

    def call
      errors = validate
      return Result.new(updated_count: 0, errors: errors) if errors.any?

      tasks = @project.tasks.open.where(id: @task_ids)

      updated = Task.transaction do
        tasks.find_each.count do |task|
          next false if task.assignee_id == @assignee.id

          task.update!(assignee: @assignee)
        end
      end

      Rails.logger.info(
        "[BulkReassign] #{@actor.email} reassigned #{updated} tasks in #{@project.identifier} to #{@assignee.email}"
      )
      Result.new(updated_count: updated, errors: [])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(updated_count: 0, errors: e.record.errors.full_messages)
    end

    private

    def validate
      errors = []
      errors << I18n.t("tasks.bulk_reassign.nothing_selected") if @task_ids.empty?
      errors << I18n.t("tasks.bulk_reassign.too_many", max: MAX_TASKS) if @task_ids.size > MAX_TASKS
      errors << I18n.t("tasks.bulk_reassign.not_allowed") unless @actor.can_manage?(@project)
      errors << I18n.t("tasks.bulk_reassign.not_a_member") unless @assignee.member_of?(@project)
      errors
    end
  end
end
