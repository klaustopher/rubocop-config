module Api
  module V1
    class TasksController < BaseController
      before_action :set_project

      def index
        tasks = @project.tasks.unarchived.includes(:assignee)
        tasks = tasks.where(updated_at: Time.iso8601(params[:since])..) if params[:since].present?

        render json: paginate(tasks.by_urgency).map { |task| serialize(task) }
      rescue ArgumentError
        render json: { error: "invalid_since" }, status: :unprocessable_content
      end

      def show
        render json: serialize(@project.tasks.find(params.expect(:id)))
      end

      def create
        task = @project.tasks.build(task_params.merge(author: current_user))

        if task.save
          render json: serialize(task), status: :created, location: api_v1_project_task_url(@project, task)
        else
          render json: { errors: task.errors.to_hash(true) }, status: :unprocessable_content
        end
      end

      private

      def set_project
        @project = Project.visible_to(current_user).find_by!(identifier: params.expect(:project_id))
      end

      def task_params
        params.expect(task: [:title, :description, :priority, :assignee_id, :due_on])
      end

      def serialize(task)
        {
          id:         task.id,
          reference:  task.reference,
          title:      task.title,
          status:     task.status,
          priority:   task.priority,
          due_on:     task.due_on&.iso8601,
          overdue:    task.overdue?,
          assignee:   task.assignee && { id: task.assignee.id, name: task.assignee.name },
          updated_at: task.updated_at.iso8601,
        }
      end
    end
  end
end
