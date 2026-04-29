FactoryBot.define do
  factory :comment do
    association :task
    association :user
    body { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
