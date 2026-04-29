class Label < ApplicationRecord
  belongs_to :project

  has_many :taggings, dependent: :destroy
  has_many :tasks, through: :taggings, source: :taggable, source_type: "Task"

  validates :name,
            presence: true,
            uniqueness: { scope: :project_id, case_sensitive: false }
  validates :color,
            presence: true,
            format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color (e.g. #ff0000)" }
end
