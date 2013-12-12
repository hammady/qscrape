class AddCommentsToVehicle < ActiveRecord::Migration
  def self.up
    add_column :vehicles, :comments, :text
  end

  def self.down
    remove_column :vehicles, :comments
  end
end
