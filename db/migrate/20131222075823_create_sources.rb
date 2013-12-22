class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :name
      t.string :url
      t.string :classname

      t.timestamps
    end

    add_column :vehicles, :source_id, :integer
    add_column :vehicles, :sid_i, :integer
    add_column :vehicles, :sid_s, :string
    add_index :vehicles, :source_id
    add_index :vehicles, :sid_i
    add_index :vehicles, :sid_s

    Source.create [
      {name: 'Qatar Living', url: 'http://www.qatarliving.com/', classname: 'QatarLivingCarScraper'},
      {name: 'Qatar Sale', url: 'http://www.qatarsale.com/', classname: 'QatarSaleCarScraper'}
    ]
  end
end
