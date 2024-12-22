class CreateRiskAnalyses < ActiveRecord::Migration[7.0]
  def change
    create_table :risk_analyses do |t|

      t.timestamps
    end
  end
end
