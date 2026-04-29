class NotificationsController < ApplicationController
  before_action :set_notification, only: [ :mark_read ]

  def index
    @pagy, @notifications = pagy(
      current_user.notifications.includes(:actor, :notifiable).recent
    )
  end

  def mark_read
    @notification.read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
