class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members

  has_many :created_tasks,
           class_name: "Task",
           foreign_key: :created_by_id,
           dependent: :nullify,
           inverse_of: :creator

  has_many :task_assignments, dependent: :destroy
  has_many :assigned_tasks, through: :task_assignments, source: :task

  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :sent_notifications,
           class_name: "Notification",
           foreign_key: :actor_id,
           dependent: :destroy,
           inverse_of: :actor

  has_many :activity_logs,
           class_name: "ActivityLog",
           foreign_key: :actor_id,
           dependent: :destroy,
           inverse_of: :actor

  validates :name, presence: true

  def initials
    name.split.map(&:first).first(2).join.upcase
  end
end
