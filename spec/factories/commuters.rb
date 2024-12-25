FactoryBot.define do
  factory :commuter do
    sequence(:commuter_id) { |n| "COM-#{n}" }
  end
end
