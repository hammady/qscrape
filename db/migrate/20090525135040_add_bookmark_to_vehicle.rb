class AddBookmarkToVehicle < ActiveRecord::Migration
  def self.up
    add_column :vehicles, :favorite, :boolean
  end

  def self.down
    remove_column :vehicles, :favorite
  end
end
