class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.belongs_to :event, index: true, null: false
      t.belongs_to :territory, null: false

      t.integer :action_type, null: false
      t.integer :territory_owner_id, null: false
      t.integer :units_difference, null: false

      t.timestamps null: false
    end
  end
end
