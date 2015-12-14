class RemoveGameFromTerritories < ActiveRecord::Migration
  def change
    remove_column :territories, :game_id, :integer
  end
end
