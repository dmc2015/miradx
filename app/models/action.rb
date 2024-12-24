class Action < ApplicationRecord
  has_many :risk_analyses
  has_many :commuter, through: :risk_analysis

  VALID_UNITS = %w[mile floor minute quantity].freeze

  validates :action, presence: true
  validates :timestamp, presence: true
  validates :unit, presence: true, inclusion: { in: VALID_UNITS }
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  validate :timestamp_format

  private

  def timestamp_format
    return if timestamp.blank?

    begin
      DateTime.parse(timestamp.to_s)
    rescue ArgumentError
      errors.add(:timestamp, 'must be a valid datetime format (YYYY-MM-DD HH:MM:SS)')
    end
  end
end
