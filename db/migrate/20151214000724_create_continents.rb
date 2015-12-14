class CreateContinents < ActiveRecord::Migration
  def change
    create_table :continents do |t|
      t.belongs_to :game, null: false
      t.string :color, null: false

      t.timestamps null: false
    end
  end
end
