FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    action  { "commented" }
    read_at { nil }

    # notifiable must be specified:
    # e.g. create(:notification, notifiable: task, user: user, actor: commenter)
    transient do
      notifiable { nil }
    end

    notifiable_type { notifiable&.class&.name }
    notifiable_id   { notifiable&.id }

    trait :read do
      read_at { 1.hour.ago }
    end
  end
end
