class ProjectsController < ApplicationController
  before_action :set_organization
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def show
    authorize @project
    board = @project.default_board
    if board
      redirect_to organization_project_board_path(@organization, @project, board)
    else
      redirect_to new_organization_project_board_path(@organization, @project),
                  notice: "Create a board to get started."
    end
  end

  def new
    @project = @organization.projects.build
    authorize @project
  end

  def create
    @project = @organization.projects.build(project_params)
    authorize @project

    if @project.save
      # Creator automatically becomes project manager
      @project.project_members.create!(user: current_user, role: :manager)
      redirect_to organization_project_path(@organization, @project),
                  notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to organization_project_path(@organization, @project),
                  notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy!
    redirect_to @organization, notice: "Project was successfully deleted."
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_project
    @project = @organization.projects.find_by!(key: params[:key].upcase)
  end

  def project_params
    params.require(:project).permit(:name, :key, :description, :status)
  end
end
