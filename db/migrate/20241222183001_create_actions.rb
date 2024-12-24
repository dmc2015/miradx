class CreateActions < ActiveRecord::Migration[7.0]
  def change
    create_table :actions do |t|
      t.datetime :timestamp
      t.string :unit
      t.decimal :quantity

      t.timestamps
    end
  end
end
