class Resource < ActiveRecord::Base
  self.table_name = :report_resources
  has_one :report

  validates_presence_of :resource
  validates_format_of :resource, :with => /^[^\[]+\[[^\]]+\]$/
end
