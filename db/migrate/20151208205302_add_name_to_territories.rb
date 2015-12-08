class AddNameToTerritories < ActiveRecord::Migration
  def up
    add_column :territories, :name, :string

    execute "UPDATE territories SET name = 'Planet ' + id"

    change_column_null :territories, :name, false
  end

  def down
    remove_column :territories, :name
  end
end
