require "rails_helper"

RSpec.describe TaskPolicy, type: :policy do
  let(:organization)   { create(:organization) }
  let(:project)        { create(:project, organization: organization) }
  let(:board)          { create(:board, project: project) }
  let(:column)         { create(:column, board: board) }
  let(:owner_user)     { create(:user) }
  let(:manager_user)   { create(:user) }
  let(:member_user)    { create(:user) }
  let(:assignee_user)  { create(:user) }
  let(:creator_user)   { create(:user) }
  let(:outside_user)   { create(:user) }

  let(:task) do
    create(:task, project: project, column: column, creator: creator_user)
  end

  before do
    create(:membership, user: owner_user,    organization: organization, role: :owner)
    create(:membership, user: manager_user,  organization: organization, role: :member)
    create(:membership, user: member_user,   organization: organization, role: :member)
    create(:membership, user: assignee_user, organization: organization, role: :member)
    create(:membership, user: creator_user,  organization: organization, role: :member)

    create(:project_member, project: project, user: manager_user,  role: :manager)
    create(:project_member, project: project, user: member_user,   role: :member)
    create(:project_member, project: project, user: assignee_user, role: :member)
    create(:project_member, project: project, user: creator_user,  role: :member)

    create(:task_assignment, task: task, user: assignee_user)
  end

  subject { described_class }

  permissions :show? do
    it { is_expected.to permit(member_user,  task) }
    it { is_expected.to permit(manager_user, task) }
    it { is_expected.not_to permit(outside_user, task) }
  end

  permissions :update? do
    it { is_expected.to permit(creator_user,  task) }
    it { is_expected.to permit(assignee_user, task) }
    it { is_expected.to permit(manager_user,  task) }
    it { is_expected.not_to permit(member_user,   task) }
    it { is_expected.not_to permit(outside_user,  task) }
  end

  permissions :destroy? do
    it { is_expected.to permit(creator_user,  task) }
    it { is_expected.to permit(manager_user,  task) }
    it { is_expected.not_to permit(assignee_user, task) }
    it { is_expected.not_to permit(member_user,   task) }
    it { is_expected.not_to permit(outside_user,  task) }
  end
end
