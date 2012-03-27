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
    return last_report.success
  end

  def self.reporting_nodes
    p Node.select { ["distinct(nodes.id)", "nodes.*"] }.
      join_table(:inner, :reports, :node_id => :id).
      filter("reports.created_at" => (DateTime.now - Rational(1,24))..DateTime.now).
      group { "nodes.id" }
  end

  def self.reporting_nodes_old
    Node.with_sql(
      %[
        select distinct(nodes.id), nodes.*
        from nodes 
          inner join reports on nodes.id = reports.node_id 
        where reports.created_at BETWEEN :x and :y
        group by nodes.id
      ], :x => DateTime.now - Rational(1, 24), :y => DateTime.now
    )
  end

  def last_report
    x = reports_dataset.order(:created_at).limit(1)
    p x
    x.all.first
  end

  def self.group_by_execution
    success, failure = Node.reporting_nodes.partition(&:last_run_success?)
    breakdown_proc = proc { |x| x.last_report.resources.map(&:resource).sort } 
    failure_breakdown = failure.group_by(&breakdown_proc)
    success_breakdown = success.group_by(&breakdown_proc)
    return { "success" => success_breakdown, "failure" => failure_breakdown }
  end
end
