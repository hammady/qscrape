class Brand < ActiveRecord::Base
  has_many :vehicle
  attr_accessible :id, :name

  def to_s
    name
  end
end
