require 'db'

class Report < ActiveRecord::Base
  has_many :resources
  has_one :node

  #def validate
    #super
    #validates_presence(:success, :allow_nil => false)
  #end
end
