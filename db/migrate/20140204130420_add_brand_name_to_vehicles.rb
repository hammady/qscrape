class AddBrandNameToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :brand_name, :string
  end
end
