class CopyBrandNameFromBrandsTable < ActiveRecord::Migration
  def up
    Vehicle.where("brand_id is not null and brand_name is null").find_each do |v|
      if v.brand
        v.brand_name = v.brand.name
        v.save
      end
    end
  end

  def down
    Vehicle.where("brand_name is not null").find_each do |v|
      v.brand = Brand.where(name: v.brand_name).first_or_create
      v.save
    end
  end
end
