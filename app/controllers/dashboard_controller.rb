class DashboardController < ApplicationController
  def index
    @organizations   = policy_scope(Organization)
    @assigned_tasks  = current_user.assigned_tasks
                                   .includes(:project, :column, :assignees)
                                   .where("due_date >= ?", Date.current)
                                   .order(:due_date)
                                   .limit(10)
    @recent_notifications = current_user.notifications
                                        .unread
                                        .includes(:actor, :notifiable)
                                        .recent
                                        .limit(5)
  end
end
