class Resource < Sequel::Model(:report_resources)
  many_to_one :report

  plugin :validation_helpers

  def validate
    super
    validates_presence(:resource, :allow_nil => false)
    validates_format(/^[^\[]+\[[^\]]+\]$/, :resource)
  end
end
