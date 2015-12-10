class CreateActionAdds < ActiveRecord::Migration
  def change
    create_table :action_adds do |t|
      t.belongs_to :territory, null: false

      t.integer :units, null: false

      t.timestamps null: false
    end
  end
end
