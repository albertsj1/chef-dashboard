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

  def last_run_success?
    unless reports.empty?
      return last_report.success
    end
    
    return false
  end

  def self.reporting_nodes
    Node.with_sql(
      %[
        select distinct(nodes.id), nodes.* 
        from nodes 
          inner join reports on nodes.id = reports.node_id 
        where reports.created_at BETWEEN :x and :y
        group by nodes.id
      ], :x => DateTime.now - 3600, :y => DateTime.now
    )
  end

  def last_report
    reports.sort_by { |x| x.created_at }.last
  end

  def self.group_by_execution
    success, failure = Node.reporting_nodes.partition { |x| x.last_run_success? }
    breakdown_proc = proc { |x| x.last_report.resources.map(&:resource).sort } 
    failure_breakdown = failure.group_by(&breakdown_proc)
    success_breakdown = success.group_by(&breakdown_proc)
    return { "success" => success_breakdown, "failure" => failure_breakdown }
  end
end
