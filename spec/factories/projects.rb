FactoryBot.define do
  factory :project do
    association :organization
    name        { Faker::App.name }
    key         { Faker::Alphanumeric.unique.alpha(number: 3).upcase }
    description { Faker::Lorem.sentence }
    status      { :active }

    trait :archived do
      status { :archived }
    end

    trait :completed do
      status { :completed }
    end
  end
end
