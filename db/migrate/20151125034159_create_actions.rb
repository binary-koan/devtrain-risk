class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.belongs_to :event
      t.belongs_to :territory
      t.integer :territory_owner_id
      t.integer :units_difference

      t.timestamps null: false
    end
  end
end
