class Node < ActiveRecord::Base
  has_many :reports

  validates_presence_of :name
  validates_presence_of :fqdn
  validates_presence_of :ipaddress
  validates_uniqueness_of [:name, :fqdn]
  validates_uniqueness_of :name

  def self.create_report(report_hash)

    raise ArgumentError, "report_hash is not a Hash" unless report_hash.kind_of?(Hash)
    raise ArgumentError, "resources is not an Array" unless report_hash['resources'].kind_of?(Array)

    node = Node.where(:name => report_hash['name']).first

    if node
      node.fqdn       = report_hash['fqdn']
      node.ipaddress  = report_hash['ipaddress']
    else
      node = Node.new(
        :name       => report_hash['name'], 
        :fqdn       => report_hash['fqdn'], 
        :ipaddress  => report_hash['ipaddress']
      )
    end

    node.reports << 
      Report.new(
        :success    => report_hash['success'], 
        :created_at => DateTime.now, 
        :resources  => report_hash['resources'].map { |x| Resource.new(:resource => x) }
      )

    node.save!
    node
  end

  def last_run_success?
    return last_report.success
  end

  def self.reporting_nodes
    Node.
      joins(:reports).
      where("reports.created_at BETWEEN ? and ?", 1.day.ago, DateTime.now).
      order("reports.created_at DESC").
      select("distinct(nodes.id), nodes.*")
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
    reports.order("created_at desc").limit(1).first
  end

  def self.group_by_execution
    success, failure = Node.reporting_nodes.partition(&:last_run_success?)
    breakdown_proc = proc { |x| x.last_report.resources.map(&:resource).sort } 
    failure_breakdown = failure.group_by(&breakdown_proc)
    success_breakdown = success.group_by(&breakdown_proc)
    return { "success" => success_breakdown, "failure" => failure_breakdown }
  end
end
