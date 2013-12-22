class AddContact2ToVehicle < ActiveRecord::Migration
  def up
    add_column :vehicles, :contact_number2, :string
    remove_column :vehicles, "[:location, :username]"
  end

  def down
    remove_column :vehicles, :contact_number2
  end
end
