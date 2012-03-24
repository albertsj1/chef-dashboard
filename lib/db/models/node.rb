require 'db'

class Node < Sequel::Model
  one_to_many :reports
end
