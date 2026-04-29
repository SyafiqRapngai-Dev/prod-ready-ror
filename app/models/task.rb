class Task < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_title,
                  against: [ :title, :description ],
                  using: { tsearch: { prefix: true } }

  belongs_to :project
  belongs_to :column
  belongs_to :creator, class_name: "User", foreign_key: :created_by_id, inverse_of: :created_tasks
  belongs_to :parent, class_name: "Task", optional: true, inverse_of: :subtasks

  has_many :subtasks,
           class_name: "Task",
           foreign_key: :parent_id,
           dependent: :destroy,
           inverse_of: :parent

  has_many :task_assignments, dependent: :destroy
  has_many :assignees, through: :task_assignments, source: :user

  has_many :comments, dependent: :destroy

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :labels, through: :taggings

  has_many :activity_logs, as: :trackable, dependent: :destroy

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true
  validates :column, presence: true
  validates :project, presence: true

  before_create :set_position

  scope :root_tasks,  -> { where(parent_id: nil) }
  scope :overdue,     -> { where("due_date < ?", Date.current).where.not(due_date: nil) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :ordered,     -> { order(:position) }

  private

  def set_position
    max = column.tasks.maximum(:position) || 0.0
    self.position = max + 1.0
  end
end
