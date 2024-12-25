FactoryBot.define do
  factory :action do
    sequence(:action) { |n| "action_#{n}" }
    unit { %w[mile floor minute quantity].sample }
    quantity { rand(1.0..10.0).round(2) }
    timestamp { Time.current }
  end
end
