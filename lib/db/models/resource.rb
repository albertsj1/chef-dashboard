class Resource < Sequel::Model(:report_resources)
  many_to_one :report
end
