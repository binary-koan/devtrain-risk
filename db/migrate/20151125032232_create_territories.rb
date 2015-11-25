class CreateTerritories < ActiveRecord::Migration
  def change
    create_table :territories do |t|
      t.belongs_to :game, null: false

      t.timestamps null: false
    end
  end
end
