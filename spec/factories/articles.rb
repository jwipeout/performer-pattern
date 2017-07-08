FactoryGirl.define do
  factory :article do
    sequence(:name) { |n| "name_#{n}" }
    sequence(:author) { |n| "first_#{n} last_#{n}" }
  end
end
