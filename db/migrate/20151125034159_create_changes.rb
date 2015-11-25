class CreateChanges < ActiveRecord::Migration
  def change
    create_table :changes do |t|
      t.integer :territory_owner_id
      t.integer :units_difference
      t.belongs_to :event

      t.timestamps null: false
    end
  end
end
