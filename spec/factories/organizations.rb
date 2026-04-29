FactoryBot.define do
  factory :organization do
    name        { Faker::Company.unique.name }
    description { Faker::Company.catch_phrase }

    # slug is auto-generated from name via before_validation callback
  end
end
