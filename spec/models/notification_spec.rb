require "rails_helper"

RSpec.describe Notification, type: :model do
  subject(:notification) { build(:notification, notifiable_type: "Task", notifiable_id: 1) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:actor).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:action) }
  end

  describe "scopes" do
    before do
      n1 = create(:notification, notifiable_type: "Task", notifiable_id: 1, read_at: nil)
      n2 = create(:notification, :read, notifiable_type: "Task", notifiable_id: 1)
    end

    it "unread scope returns notifications without read_at" do
      expect(Notification.unread.count).to eq(1)
    end

    it "read scope returns notifications with read_at" do
      expect(Notification.read.count).to eq(1)
    end
  end

  describe "#read!" do
    it "sets read_at timestamp" do
      notification = create(:notification, notifiable_type: "Task", notifiable_id: 1, read_at: nil)
      expect { notification.read! }.to change { notification.read_at }.from(nil)
    end

    it "does not update if already read" do
      original_time = 1.hour.ago
      notification = create(:notification, :read, notifiable_type: "Task", notifiable_id: 1, read_at: original_time)
      notification.read!
      expect(notification.reload.read_at.to_i).to eq(original_time.to_i)
    end
  end
end
