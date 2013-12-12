class Vehicle < ActiveRecord::Base
  belongs_to :brand
  
  attr_accessible :title, :url, :vtype, :location, :username, :timestamp, :contact_number, :price, :model, :mileage, :description

  def opened?
    return (viewed_at != nil or notified_at != nil)
  end
end
