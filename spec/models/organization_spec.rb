require "rails_helper"

RSpec.describe Organization, type: :model do
  subject(:organization) { build(:organization) }

  describe "associations" do
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:memberships) }
    it { is_expected.to have_many(:projects).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }

    context "with existing slug" do
      before { create(:organization, name: "Test Org") }

      it "validates slug uniqueness" do
        org = build(:organization)
        org.slug = Organization.first.slug
        expect(org).not_to be_valid
        expect(org.errors[:slug]).to be_present
      end
    end
  end

  describe "slug generation" do
    it "auto-generates slug from name before validation" do
      org = build(:organization, name: "My Company", slug: nil)
      org.valid?
      expect(org.slug).to eq("my-company")
    end

    it "does not overwrite existing slug" do
      org = build(:organization, name: "My Company", slug: "custom-slug")
      org.valid?
      expect(org.slug).to eq("custom-slug")
    end
  end

  describe ".for_user scope" do
    let(:user) { create(:user) }
    let(:org)  { create(:organization) }

    before { create(:membership, user: user, organization: org) }

    it "returns organizations where user is a member" do
      other_org = create(:organization)
      expect(Organization.for_user(user)).to include(org)
      expect(Organization.for_user(user)).not_to include(other_org)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      org = create(:organization, name: "Test Org")
      expect(org.to_param).to eq(org.slug)
    end
  end
end
