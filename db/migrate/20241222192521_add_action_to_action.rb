# frozen_string_literal: true

class AddActionToAction < ActiveRecord::Migration[7.0]
  def change
    add_column :actions, :action, :string
  end
end
