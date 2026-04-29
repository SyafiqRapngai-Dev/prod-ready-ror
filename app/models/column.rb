class Column < ApplicationRecord
  belongs_to :board, inverse_of: :columns

  has_many :tasks, -> { order(:position) }, dependent: :nullify, inverse_of: :column

  validates :name, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  before_create :set_position

  scope :ordered, -> { order(:position) }

  private

  def set_position
    max = board.columns.maximum(:position) || 0
    self.position = max + 1
  end
end
