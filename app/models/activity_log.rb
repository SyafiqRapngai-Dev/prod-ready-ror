class ActivityLog < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :actor, class_name: "User", inverse_of: :activity_logs

  validates :action, presence: true

  scope :recent,        -> { order(created_at: :desc) }
  scope :for_trackable, ->(record) { where(trackable: record) }
end
