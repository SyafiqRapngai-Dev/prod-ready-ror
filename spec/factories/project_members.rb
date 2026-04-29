FactoryBot.define do
  factory :project_member do
    association :project
    association :user
    role { :member }

    trait :manager do
      role { :manager }
    end
  end
end
