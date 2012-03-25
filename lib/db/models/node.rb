require 'db'

class Node < Sequel::Model
  one_to_many :reports

  def self.create_report(report_hash)
    node = Node.filter(:name => report_hash['name']).first

    if node
      node.update(
        :fqdn => report_hash['fqdn'], 
        :ipaddress => report_hash['ipaddress']
      )
    else
      node = Node.create(
        :name => report_hash['name'], 
        :fqdn => report_hash['fqdn'], 
        :ipaddress => report_hash['ipaddress']
      )
    end

    node.add_report(
      Report.create(
        :success => true, 
        :created_at => DateTime.now, 
        :resources => report_hash['resources'].map { |x| Resource.create(:resource => x) }
      )
    )

    node

  end
end
