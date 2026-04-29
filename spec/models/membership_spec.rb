require "rails_helper"

RSpec.describe Membership, type: :model do
  subject(:membership) { build(:membership) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    it "validates uniqueness of user_id scoped to organization_id" do
      existing = create(:membership)
      duplicate = build(:membership, user: existing.user, organization: existing.organization)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  describe "enum roles" do
    it { is_expected.to define_enum_for(:role).with_values(member: 1, admin: 2, owner: 3) }
  end

  describe "scopes" do
    before do
      create(:membership, :owner)
      create(:membership, :admin)
      create(:membership)
    end

    it { expect(Membership.owners.count).to eq(1) }
    it { expect(Membership.admins.count).to eq(1) }
    it { expect(Membership.members.count).to eq(1) }
  end
end
