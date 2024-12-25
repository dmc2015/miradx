# frozen_string_literal: true

class CreateRiskAnalyses < ActiveRecord::Migration[7.0]
  def change
    create_table :risk_analyses, &:timestamps
  end
end
