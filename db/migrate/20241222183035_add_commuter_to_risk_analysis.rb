class AddCommuterToRiskAnalysis < ActiveRecord::Migration[7.0]
  def change
    add_reference :risk_analyses, :commuter, null: false, foreign_key: true
    add_reference :risk_analyses, :action, null: false, foreign_key: true
  end
end
