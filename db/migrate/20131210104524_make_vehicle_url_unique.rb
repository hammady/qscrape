class MakeVehicleUrlUnique < ActiveRecord::Migration
  def change
    add_index :vehicles, :url, :unique => true
  end
end
