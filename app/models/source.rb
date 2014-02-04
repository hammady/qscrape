class Source < ActiveRecord::Base
  attr_accessible :id, :classname, :name, :url

  has_many :vehicles

  def to_s
    name
  end
end
