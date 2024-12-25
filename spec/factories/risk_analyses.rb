FactoryBot.define do
  factory :risk_analysis, aliases: [:commuter_action] do
    association :commuter
    association :action

    trait :with_mile_action do
      association :action, unit: 'mile'
    end

    trait :with_floor_action do
      association :action, unit: 'floor'
    end

    trait :with_minute_action do
      association :action, unit: 'minute'
    end
  end
end
