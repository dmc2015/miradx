class Commuter < ApplicationRecord
  has_many :risk_analyses
  has_many :actions, through: :risk_analyses

  validates :commuter_id, presence: true, uniqueness: true
end
