class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :event_type, null: false
      t.belongs_to :player

      t.timestamps null: false
    end
  end
end
