class Project < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_name,
                  against: [ :name, :description ],
                  using: { tsearch: { prefix: true } }

  belongs_to :organization

  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user
  has_many :boards, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :labels, dependent: :destroy

  enum :status, { active: 0, archived: 1, completed: 2 }

  validates :name, presence: true
  validates :key,
            presence: true,
            uniqueness: { scope: :organization_id, case_sensitive: false },
            format: { with: /\A[A-Z0-9]+\z/, message: "only allows uppercase letters and numbers" }

  before_validation :upcase_key

  scope :active,    -> { where(status: :active) }
  scope :for_user,  ->(user) { joins(:project_members).where(project_members: { user_id: user.id }) }

  def to_param
    key
  end

  def default_board
    boards.first
  end

  private

  def upcase_key
    self.key = key&.upcase
  end
end
