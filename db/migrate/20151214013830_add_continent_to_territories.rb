class AddContinentToTerritories < ActiveRecord::Migration
  def change
    add_reference :territories, :continent, index: true, foreign_key: true
  end
end
