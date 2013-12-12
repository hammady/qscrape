class AddTimestampToVehicle < ActiveRecord::Migration
  def up
    add_column :vehicles, :timestamp, :datetime
    remove_column :vehicles, :submit_date
    remove_column :vehicles, :submit_time
  end

  def down
    add_column :vehicles, :submit_date, :string
    add_column :vehicles, :submit_time, :string
    remove_column :vehicles, :timestamp
  end
end
