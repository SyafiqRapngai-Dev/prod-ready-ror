class CommentsController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_task
  before_action :set_comment, only: [ :update, :destroy ]

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organization_project_task_path(@organization, @project, @task) }
      end
    else
      respond_to do |format|
        format.html { redirect_to organization_project_task_path(@organization, @project, @task), alert: "Could not save comment." }
      end
    end
  end

  def update
    authorize @comment

    if @comment.update(comment_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organization_project_task_path(@organization, @project, @task) }
      end
    else
      respond_to do |format|
        format.html { redirect_to organization_project_task_path(@organization, @project, @task), alert: "Could not update comment." }
      end
    end
  end

  def destroy
    authorize @comment
    @comment.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_project_task_path(@organization, @project, @task) }
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
    @task = @project.tasks.find(params[:task_id])
  end

  def set_comment
    @comment = @task.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
