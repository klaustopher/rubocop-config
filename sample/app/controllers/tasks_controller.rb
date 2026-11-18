class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    tasks = @project.tasks.unarchived.includes(:assignee, :author)
    tasks = tasks.where(status: params[:status]) if Task.statuses.key?(params[:status])
    tasks = tasks.assigned_to(current_user) if params[:mine] == "1"

    @tasks = tasks.search(params[:q]).by_urgency
  end

  def show
    @subtasks = @task.subtasks.order(:created_at)
  end

  def new
    @task = @project.tasks.build(parent_id: params[:parent_id])
  end

  def edit; end

  def create
    @task = @project.tasks.build(task_params.merge(author: current_user))

    if @task.save
      redirect_to [@project, @task], notice: t(".created", reference: @task.reference)
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to [@project, @task], notice: t(".updated") }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream { render :edit, status: :unprocessable_content }
      end
    end
  end

  def destroy
    @task.destroy!
    redirect_to project_tasks_path(@project), notice: t(".destroyed"), status: :see_other
  end

  def bulk_reassign
    result = Tasks::BulkReassign.new(
      project:  @project,
      task_ids: params.fetch(:task_ids, []),
      assignee: @project.members.find(params.expect(:assignee_id)),
      actor:    current_user
    ).call

    if result.success?
      redirect_to project_tasks_path(@project), notice: t(".reassigned", count: result.updated_count)
    else
      redirect_to project_tasks_path(@project), alert: result.errors.to_sentence
    end
  end

  private

  def set_project
    @project = Project.visible_to(current_user).find_by!(identifier: params.expect(:project_id))
  end

  def set_task
    @task = @project.tasks.find(params.expect(:id))
  end

  def task_params
    params.expect(task: [:title, :description, :status, :priority, :assignee_id, :parent_id, :due_on, :estimated_hours])
  end
end
