class Resource < ActiveRecord::Base
  self.table_name = :report_resources
  has_one :report

  #def validate
    #super
    #validates_presence(:resource, :allow_nil => false)
    #validates_format(/^[^\[]+\[[^\]]+\]$/, :resource)
  #end
end
