class ColumnsController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_board
  before_action :set_column, only: [ :update, :destroy, :move ]

  def new
    @column = @board.columns.build
    authorize @column
  end

  def create
    @column = @board.columns.build(column_params)
    authorize @column

    if @column.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organization_project_board_path(@organization, @project, @board) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("column_form", partial: "columns/form", locals: { column: @column, board: @board, organization: @organization, project: @project }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @column

    if @column.update(column_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to organization_project_board_path(@organization, @project, @board) }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @column
    @column.destroy!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_project_board_path(@organization, @project, @board) }
    end
  end

  def move
    authorize @column, :update?
    @column.update!(position: params[:position].to_i)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to organization_project_board_path(@organization, @project, @board) }
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
    @board = @project.boards.find(params[:board_id])
  end

  def set_column
    @column = @board.columns.find(params[:id])
  end

  def column_params
    params.require(:column).permit(:name, :color, :position)
  end
end
