class Tagging < ApplicationRecord
  belongs_to :label
  belongs_to :taggable, polymorphic: true

  validates :label_id,
            uniqueness: { scope: [ :taggable_type, :taggable_id ], message: "has already been applied" }
end
