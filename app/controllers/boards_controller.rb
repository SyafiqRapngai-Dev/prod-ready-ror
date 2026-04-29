class BoardsController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_board, only: [ :show ]

  def show
    authorize @board
    @columns = @board.columns.includes(tasks: [ :assignees, :labels, :creator ])
  end

  def new
    @board = @project.boards.build
    authorize @board
  end

  def create
    @board = @project.boards.build(board_params)
    authorize @board

    if @board.save
      redirect_to organization_project_board_path(@organization, @project, @board),
                  notice: "Board was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_project
    @project = @organization.projects.find_by!(key: params[:project_key].upcase)
  end

  def set_board
    @board = @project.boards.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:name)
  end
end
