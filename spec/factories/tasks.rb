FactoryBot.define do
  factory :task do
    association :project
    association :column
    association :creator, factory: :user
    title       { Faker::Lorem.sentence(word_count: 5) }
    description { Faker::Lorem.paragraph }
    priority    { :medium }
    position    { 1.0 }

    trait :urgent do
      priority  { :urgent }
      due_date  { 1.day.from_now }
    end

    trait :overdue do
      due_date  { 2.days.ago }
    end

    trait :with_subtask do
      after(:create) do |task|
        create(:task, project: task.project, column: task.column, creator: task.creator, parent: task)
      end
    end
  end
end
