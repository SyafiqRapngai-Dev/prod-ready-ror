FactoryBot.define do
  factory :tagging do
    association :label

    # taggable must be specified by the test:
    # e.g. create(:tagging, label: label, taggable: task)
    transient do
      taggable { nil }
    end

    taggable_type { taggable&.class&.name }
    taggable_id   { taggable&.id }
  end
end
