class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    if @query.length >= 2
      org_ids     = current_user.organizations.pluck(:id)
      project_ids = current_user.projects.pluck(:id)

      @projects = Project.where(organization_id: org_ids)
                         .search_by_name(@query)
                         .limit(5)

      @tasks = Task.where(project_id: project_ids)
                   .search_by_title(@query)
                   .includes(:project, :column)
                   .limit(10)
    else
      @projects = Project.none
      @tasks    = Task.none
    end
  end
end
