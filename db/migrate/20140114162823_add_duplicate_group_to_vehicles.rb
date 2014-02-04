class AddDuplicateGroupToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :duplicate_group, :integer
    add_index :vehicles, :duplicate_group
  end
end
