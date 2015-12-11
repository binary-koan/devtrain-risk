class AddSourceTerritoryToKillAction < ActiveRecord::Migration
  def up
    add_column :action_kills, :territory_from_id, :integer

    execute "UPDATE action_kills SET territory_from_id = 0"

    change_column_null :action_kills, :territory_from_id, false
  end

  def down
    remove_column :action_kills, :territory_from_id
  end
end
