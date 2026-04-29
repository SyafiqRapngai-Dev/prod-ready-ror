class Board < ApplicationRecord
  belongs_to :project

  has_many :columns, -> { order(:position) }, dependent: :destroy, inverse_of: :board

  validates :name, presence: true

  def to_param
    id.to_s
  end
end
