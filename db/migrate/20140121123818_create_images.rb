class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.primary_key :id
      t.string :url
      t.references :vehicle

      t.timestamps
    end
    add_index :images, :vehicle_id
  end
end
