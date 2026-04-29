class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  has_many :activity_logs, as: :trackable, dependent: :destroy

  validates :body, presence: true

  after_create_commit :enqueue_notification_job

  private

  def enqueue_notification_job
    NotificationJob.perform_later(
      "Comment", id, user_id, "commented"
    )
  end
end
