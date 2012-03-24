require 'db'

class Report < Sequel::Model
  one_to_many :resources
  many_to_one :node
end
