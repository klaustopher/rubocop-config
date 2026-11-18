class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :archive]
  before_action :require_manager, only: [:edit, :update, :destroy, :archive]

  def index
    @projects = Project.visible_to(current_user)
      .unarchived
      .includes(:memberships, logo_attachment: :blob)
      .order(:name)
  end

  def show
    @tasks = @project.tasks
      .unarchived
      .includes(:assignee)
      .search(params[:q])
      .by_urgency
    @summary = Reports::ProjectSummary.new(@project).call
  end

  def new
    @project = Project.new
  end

  def edit; end

  def create
    @project = Project.new(project_params)

    Project.transaction do
      @project.save!
      @project.memberships.create!(user: current_user, role: "owner")
    end

    redirect_to @project, notice: t(".created", name: @project.name)
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_path, notice: t(".destroyed"), status: :see_other
  end

  def archive
    @project.archive!(by: current_user)
    redirect_to projects_path, notice: t(".archived", name: @project.name)
  end

  private

  def set_project
    @project = Project.visible_to(current_user).find_by!(identifier: params.expect(:id))
  end

  def require_manager
    raise NotAuthorizedError unless current_user.can_manage?(@project)
  end

  def project_params
    params.expect(project: [:name, :identifier, :description, :budget_cents, :logo])
  end
end
