class TasksController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_task, only: [ :show, :edit, :update, :destroy, :move ]

  def index
    @pagy, @tasks = pagy(
      policy_scope(@project.tasks).root_tasks.includes(:column, :assignees, :labels, :creator).ordered
    )
  end

  def show
    authorize @task
    @comments     = @task.comments.includes(:user).order(:created_at)
    @activity_logs = @task.activity_logs.includes(:actor).recent
    @subtasks     = @task.subtasks.includes(:column, :assignees)
    @new_comment  = Comment.new
  end

  def new
    @task = @project.tasks.build(column_id: params[:column_id])
    authorize @task
    @columns = @project.boards.first&.columns&.ordered || Column.none
    @labels  = @project.labels
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.creator = current_user
    authorize @task

    if @task.save
      ActivityLogJob.perform_later("Task", @task.id, current_user.id, "created", { title: @task.title })

      board = @task.column&.board || @project.boards.first
      redirect_to organization_project_board_path(@organization, @project, board), status: :see_other, notice: "Task was successfully created."
    else
      @columns = @project.boards.first&.columns&.ordered || Column.none
      @labels  = @project.labels
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("task_form", partial: "tasks/form", locals: { task: @task, organization: @organization, project: @project, columns: @columns, labels: @labels }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @task
    @columns = @project.boards.first&.columns&.ordered || Column.none
    @labels  = @project.labels
  end

  def update
    authorize @task

    if @task.update(task_params)
      ActivityLogJob.perform_later("Task", @task.id, current_user.id, "updated", { title: @task.title })

      board = @task.column.board
      redirect_to organization_project_board_path(@organization, @project, board), status: :see_other, notice: "Task was successfully updated."
    else
      @columns = @project.boards.first&.columns&.ordered || Column.none
      @labels  = @project.labels
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    column = @task.column
    @task.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_project_board_path(@organization, @project, column.board), notice: "Task was successfully deleted." }
    end
  end

  def move
    authorize @task, :update?
    target_column = Column.joins(board: :project).find_by(id: params[:column_id], boards: { project_id: @project.id })
    return head :forbidden unless target_column

    @task.update!(
      column_id: target_column.id,
      position:  params[:position].to_f
    )

    ActivityLogJob.perform_later("Task", @task.id, current_user.id, "moved")

    respond_to do |format|
      format.turbo_stream
      format.html { head :ok }
    end
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_project
    @project = @organization.projects.find_by!(key: params[:project_key].upcase)
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :column_id, :priority, :due_date, :parent_id,
      assignee_ids: [], label_ids: []
    )
  end
end
