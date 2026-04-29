class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { member: 1, admin: 2, owner: 3 }

  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member of this organization" }
  validates :role, presence: true

  scope :owners,  -> { where(role: :owner) }
  scope :admins,  -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }
end
