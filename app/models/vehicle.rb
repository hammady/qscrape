class Vehicle < ActiveRecord::Base
  belongs_to :brand
  belongs_to :source
  
  attr_accessible :title, :url, :vtype, :location, :username, :timestamp, :contact_number, :contact_number2, :price, :model, :mileage, :description
  attr_accessible :class_name, :trim_name, :outside_color, :gear, :cylinders, :inside_color, :inside_type, :sunroof, :sensors, :camera, :dvd, :cd, :bluetooth, :gps
  attr_accessible :sid_i, :sid_s, :source_id

  def opened?
    return (viewed_at != nil or notified_at != nil)
  end

  def find_by_largest_sid_i
    order("sid_i desc").first
  end

  def find_by_largest_sid_s
    order("sid_s desc").first
  end

  def find_by_smallest_sid_i
    order("sid_i asc").first
  end

  def find_by_smallest_sid_s
    order("sid_s asc").first
  end
end
