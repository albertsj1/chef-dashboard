require 'db'

class Report < Sequel::Model
  one_to_many :resources
  many_to_one :node

  plugin :validation_helpers

  def validate
    super
    validates_presence(:success, :allow_nil => false)
  end

  def resources=(resources)
    save unless id
    remove_all_resources 
    add_resources(resources)
  end

  def add_resources(resources)
    resources.each do |resource|
      add_resource(resource)
    end
  end

end
