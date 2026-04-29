require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  let(:organization) { create(:organization) }
  let(:owner_user)   { create(:user) }
  let(:admin_user)   { create(:user) }
  let(:member_user)  { create(:user) }
  let(:outside_user) { create(:user) }

  before do
    create(:membership, user: owner_user,  organization: organization, role: :owner)
    create(:membership, user: admin_user,  organization: organization, role: :admin)
    create(:membership, user: member_user, organization: organization, role: :member)
  end

  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(owner_user,  organization) }
    it { is_expected.to permit(admin_user,  organization) }
    it { is_expected.to permit(member_user, organization) }
    it { is_expected.not_to permit(outside_user, organization) }
  end

  permissions :create? do
    it { is_expected.to permit(outside_user, organization) }
  end

  permissions :update? do
    it { is_expected.to permit(owner_user, organization) }
    it { is_expected.to permit(admin_user, organization) }
    it { is_expected.not_to permit(member_user, organization) }
    it { is_expected.not_to permit(outside_user, organization) }
  end

  permissions :destroy? do
    it { is_expected.to permit(owner_user,  organization) }
    it { is_expected.not_to permit(admin_user,  organization) }
    it { is_expected.not_to permit(member_user, organization) }
    it { is_expected.not_to permit(outside_user, organization) }
  end
end
