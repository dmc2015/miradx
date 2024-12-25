# frozen_string_literal: true

class RiskAnalysis < ApplicationRecord
  belongs_to :commuter
  belongs_to :action
end
