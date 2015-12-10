class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :action_id
      t.string :action_type

      t.belongs_to :player, index: true, null: false
      t.belongs_to :game, null: false

      t.string :event_type, null: false

      t.timestamps null: false
    end
  end
end
