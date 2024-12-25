# frozen_string_literal: true

class Action < ApplicationRecord
  has_many :risk_analyses
  has_many :commuters, through: :risk_analyses

  VALID_UNITS = %w[mile floor minute quantity].freeze
  UNIT_MAPPING = {
    floor: 20,
    mile: 10,
    quantity: 1,
    minute: 5
  }.freeze

  validates :action, presence: true
  validates :timestamp, presence: true
  validates :unit, presence: true, inclusion: { in: VALID_UNITS }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def self.valid_dates?(actions)
    return false if actions.blank?

    first_action = parse_timestamp(actions.first)
    return false unless first_action

    return true if actions.size == 1

    day_start = first_action.beginning_of_day
    day_end = first_action.tomorrow.midnight - 1.second

    actions.drop(1).all? do |action|
      current_date = parse_timestamp(action)

      current_date.between?(day_start, day_end)
    end
  rescue ArgumentError, TypeError => e
    Rails.logger.error("Date parsing error in valid_dates?: #{e.message}")
    false
  end

  def self.parse_timestamp(action)
    time_stamp = action[:timestamp]
    return nil if time_stamp.nil?

    DateTime.strptime(time_stamp, '%Y-%m-%d %H:%M:%S')
  rescue ArgumentError, TypeError
    nil
  end
end
