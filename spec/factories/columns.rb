FactoryBot.define do
  factory :column do
    association :board
    name     { Faker::Lorem.word.capitalize }
    position { 1 }
    color    { "#6366f1" }

    trait :backlog do
      name     { "Backlog" }
      position { 1 }
      color    { "#94a3b8" }
    end

    trait :in_progress do
      name     { "In Progress" }
      position { 2 }
      color    { "#3b82f6" }
    end

    trait :done do
      name     { "Done" }
      position { 3 }
      color    { "#22c55e" }
    end
  end
end
