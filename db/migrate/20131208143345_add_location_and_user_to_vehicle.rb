class AddLocationAndUserToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :location, :string
    add_column :vehicles, :username, :string
  end
end
