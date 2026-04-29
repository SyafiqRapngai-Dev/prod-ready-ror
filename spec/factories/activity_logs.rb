FactoryBot.define do
  factory :activity_log do
    association :actor, factory: :user
    action   { "created" }
    metadata { {} }

    # trackable must be specified:
    # e.g. create(:activity_log, trackable: task, actor: user, action: "created")
    transient do
      trackable { nil }
    end

    trackable_type { trackable&.class&.name }
    trackable_id   { trackable&.id }
  end
end
