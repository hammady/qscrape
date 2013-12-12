class AddViewdAtToVehicle < ActiveRecord::Migration
  def self.up
    add_column :vehicles, :viewed_at, :datetime
  end

  def self.down
    remove_column :vehicles, :viewed_at
  end
end
