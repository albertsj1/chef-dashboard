require 'db'

class Node < Sequel::Model
  one_to_many :reports

  plugin :validation_helpers

  def validate
    super
    validates_presence([:name, :fqdn, :ipaddress], :allow_nil => false)
    validates_unique([:name, :fqdn])
    validates_unique(:name)
  end

  def self.create_report(report_hash)

    raise ArgumentError, "report_hash is not a Hash" unless report_hash.kind_of?(Hash)
    raise ArgumentError, "resources is not an Array" unless report_hash['resources'].kind_of?(Array)

    node = Node.filter(:name => report_hash['name']).first

    if node
      node.update(
        :fqdn       => report_hash['fqdn'], 
        :ipaddress  => report_hash['ipaddress']
      )
    else
      node = Node.create(
        :name       => report_hash['name'], 
        :fqdn       => report_hash['fqdn'], 
        :ipaddress  => report_hash['ipaddress']
      )
    end

    node.add_report(
      Report.create(
        :success    => report_hash['success'], 
        :created_at => DateTime.now, 
        :resources  => report_hash['resources'].map { |x| Resource.create(:resource => x) }
      )
    )

    node

  end
end
