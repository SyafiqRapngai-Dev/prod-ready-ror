FactoryBot.define do
  factory :label do
    association :project
    name  { Faker::Lorem.unique.word.capitalize }
    color { "#" + Faker::Color.hex_color.delete("#") }
  end
end
