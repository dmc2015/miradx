# frozen_string_literal: true

FactoryBot.define do
  factory :commuter do
    sequence(:commuter_id) { |n| "COM-#{n}" }
  end
end
