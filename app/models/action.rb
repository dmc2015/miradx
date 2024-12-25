class Action < ApplicationRecord
  has_many :risk_analyses
  has_many :commuters, through: :risk_analyses

  VALID_UNITS = %w[mile floor minute quantity].freeze
  UNIT_MAPPING = {
    "floor": 20,
    "mile": 10,
    "quantity": 1,
    "minute": 5
  }.freeze

  validates :action, presence: true
  validates :timestamp, presence: true
  validates :unit, presence: true, inclusion: { in: VALID_UNITS }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def self.valid_dates?(actions)
    morning_action_day = nil
    night_action_day = nil

    actions.each do |action|
      action_date = DateTime.strptime(action['timestamp'], '%Y-%m-%d %H:%M:%S')
      if morning_action_day.nil?
        morning_action_day = action_date.midnight
        night_action_day = action_date.tomorrow.midnight - 1.minute
        next
      end

      return morning_action_day <= action_date && night_action_day >= action_date
    end
  end
end
