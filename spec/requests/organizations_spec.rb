require "rails_helper"

RSpec.describe "Organizations", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before { create(:membership, user: user, organization: organization, role: :owner) }

  describe "GET /organizations" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get organizations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns success" do
        get organizations_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /organizations/:slug" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get organization_path(organization)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated as member" do
      before { sign_in user }

      it "returns success" do
        get organization_path(organization)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as non-member" do
      let(:outsider) { create(:user) }
      before { sign_in outsider }

      it "redirects with not authorized" do
        get organization_path(organization)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /organizations" do
    before { sign_in user }

    it "creates organization and auto-assigns owner membership" do
      expect {
        post organizations_path, params: {
          organization: { name: "New Org", description: "Test" }
        }
      }.to change(Organization, :count).by(1)
        .and change(Membership, :count).by(1)

      new_org = Organization.last
      expect(new_org.memberships.first.role).to eq("owner")
      expect(response).to redirect_to(organization_path(new_org))
    end
  end
end
