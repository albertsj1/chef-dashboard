require 'db'

class Report < ActiveRecord::Base
  has_many :resources
  has_one :node

  validates_inclusion_of :success, :in => [true, false]
end
