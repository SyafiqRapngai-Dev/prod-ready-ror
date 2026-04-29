class TaskAssignment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :user_id,
            uniqueness: { scope: :task_id, message: "is already assigned to this task" }

  after_create_commit :enqueue_notification_job

  private

  def enqueue_notification_job
    NotificationJob.perform_later(
      "Task", task_id, user_id, "assigned"
    )
  end
end
