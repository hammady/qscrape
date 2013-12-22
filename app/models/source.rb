class Source < ActiveRecord::Base
  attr_accessible :id, :classname, :name, :url

  has_many :vehicles
end
