FactoryBot.define do
  factory :task_assignment do
    association :task
    association :user
  end
end
