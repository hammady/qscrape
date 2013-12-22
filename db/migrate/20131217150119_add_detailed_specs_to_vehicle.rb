class AddDetailedSpecsToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :class_name, :string
    add_column :vehicles, :trim_name, :string
    add_column :vehicles, :outside_color, :string
    add_column :vehicles, :gear, :string
    add_column :vehicles, :cylinders, :integer
    add_column :vehicles, :inside_color, :string
    add_column :vehicles, :inside_type, :string
    add_column :vehicles, :sunroof, :boolean
    add_column :vehicles, :sensors, :boolean
    add_column :vehicles, :camera, :boolean
    add_column :vehicles, :dvd, :boolean
    add_column :vehicles, :cd, :boolean
    add_column :vehicles, :bluetooth, :boolean
    add_column :vehicles, :gps, :boolean
  end
end
