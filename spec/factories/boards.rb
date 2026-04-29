FactoryBot.define do
  factory :board do
    association :project
    name { "Main Board" }
  end
end
