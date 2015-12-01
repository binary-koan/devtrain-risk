class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_type, null: false
      t.belongs_to :player, null: false
      t.belongs_to :game, null: false

      t.timestamps null: false
    end
  end
end
