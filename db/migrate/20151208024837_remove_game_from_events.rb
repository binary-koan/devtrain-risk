class RemoveGameFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :game_id, :integer
  end
end
