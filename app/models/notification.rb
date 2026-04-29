class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User", inverse_of: :sent_notifications
  belongs_to :notifiable, polymorphic: true

  validates :action, presence: true

  scope :unread,  -> { where(read_at: nil) }
  scope :read,    -> { where.not(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  def read!
    update!(read_at: Time.current) unless read_at?
  end

  def unread?
    read_at.nil?
  end

  def display_message
    actor_name = actor.name
    resource_name = notifiable.try(:title) || notifiable.try(:body)&.truncate(50) || notifiable.class.name.humanize

    case action
    when "assigned"      then "#{actor_name} assigned you to #{resource_name}"
    when "commented"     then "#{actor_name} commented on #{resource_name}"
    when "task_created"  then "#{actor_name} created #{resource_name}"
    when "status_changed" then "#{actor_name} updated #{resource_name}"
    else "#{actor_name} performed #{action} on #{resource_name}"
    end
  end
end
