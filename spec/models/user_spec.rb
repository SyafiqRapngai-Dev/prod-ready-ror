require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:organizations).through(:memberships) }
    it { is_expected.to have_many(:project_members).dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:project_members) }
    it { is_expected.to have_many(:task_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:notifications).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "#initials" do
    it "returns first letter of first and last name" do
      user = build(:user, name: "Alice Chen")
      expect(user.initials).to eq("AC")
    end

    it "returns single initial for single name" do
      user = build(:user, name: "Alice")
      expect(user.initials).to eq("A")
    end
  end
end
