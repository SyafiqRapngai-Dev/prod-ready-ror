require "rails_helper"

RSpec.describe Task, type: :model do
  subject(:task) { build(:task) }

  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:column) }
    it { is_expected.to belong_to(:creator).class_name("User") }
    it { is_expected.to belong_to(:parent).class_name("Task").optional }
    it { is_expected.to have_many(:subtasks).class_name("Task") }
    it { is_expected.to have_many(:task_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:taggings) }
    it { is_expected.to have_many(:activity_logs) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:column) }
    it { is_expected.to validate_presence_of(:project) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, urgent: 3) }
  end

  describe "scopes" do
    let(:project) { create(:project) }
    let(:column)  { create(:column, board: create(:board, project: project)) }
    let(:creator) { create(:user) }

    describe ".root_tasks" do
      it "returns only tasks without a parent" do
        root_task  = create(:task, project: project, column: column, creator: creator)
        child_task = create(:task, project: project, column: column, creator: creator, parent: root_task)
        expect(Task.root_tasks).to include(root_task)
        expect(Task.root_tasks).not_to include(child_task)
      end
    end

    describe ".overdue" do
      it "returns tasks with past due dates" do
        overdue_task = create(:task, :overdue, project: project, column: column, creator: creator)
        future_task  = create(:task, project: project, column: column, creator: creator, due_date: 1.week.from_now)
        expect(Task.overdue).to include(overdue_task)
        expect(Task.overdue).not_to include(future_task)
      end
    end
  end
end
