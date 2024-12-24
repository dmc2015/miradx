class CreateCommuters < ActiveRecord::Migration[7.0]
  def change
    create_table :commuters do |t|
      t.string :commuter_id

      t.timestamps
    end
  end
end
