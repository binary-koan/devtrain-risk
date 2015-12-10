class CreateActionMoves < ActiveRecord::Migration
  def change
    create_table :action_moves do |t|
      t.integer :territory_from_id, null: false
      t.integer :territory_to_id, null: false

      t.integer :units

      t.timestamps null: false
    end
  end
end
