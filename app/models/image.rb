class Image < ActiveRecord::Base
  belongs_to :vehicle
  attr_accessible :id, :url
end
