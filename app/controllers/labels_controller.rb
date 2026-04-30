class LabelsController < ApplicationController
  before_action :set_organization
  before_action :set_project
  before_action :set_label, only: [ :show, :edit, :update, :destroy ]

  def index
    @labels = @project.labels
    authorize @project.labels.build, :index?
  end

  def show
    authorize @label
  end

  def new
    @label = @project.labels.build
    authorize @label
  end

  def create
    @label = @project.labels.build(label_params)
    authorize @label

    if @label.save
      redirect_to organization_project_labels_path(@organization, @project),
                  notice: "Label was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @label
  end

  def update
    authorize @label

    if @label.update(label_params)
      redirect_to organization_project_labels_path(@organization, @project),
                  notice: "Label was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @label
    @label.destroy!
    redirect_to organization_project_labels_path(@organization, @project),
                notice: "Label was successfully deleted."
  end

  private

  def set_organization
    @organization = Organization.find_by!(slug: params[:organization_slug])
  end

  def set_project
    @project = @organization.projects.find_by!(key: params[:project_key].upcase)
  end

  def set_label
    @label = @project.labels.find(params[:id])
  end

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
