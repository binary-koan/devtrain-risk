class CreateTerritoryLinks < ActiveRecord::Migration
  def change
    create_table :territory_links do |t|
      t.integer :from_territory_id, null: false
      t.integer :to_territory_id, null: false

      t.timestamps null: false
    end
  end
end
