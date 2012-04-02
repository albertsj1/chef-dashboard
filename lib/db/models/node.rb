class Node < ActiveRecord::Base
  has_many :reports

  validates_presence_of :name
  validates_presence_of :fqdn
  validates_presence_of :ipaddress
  validates_uniqueness_of [:name, :fqdn]
  validates_uniqueness_of :name

  def self.create_report(report_hash, created_at = DateTime.now)

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
        :created_at => created_at,
        :resources  => report_hash['resources'].map { |x| Resource.new(:resource => x) }
      )

    node.save!
    node
  end

  def last_run_success?
    return last_report.success
  end

  def self.reporting_nodes(min_time = 1.hour.ago, max_time = DateTime.now)
    Node.
      joins(:reports).
      where("reports.created_at BETWEEN ? and ?", min_time, max_time).
      order("reports.created_at DESC").
      select("distinct(nodes.id), nodes.*")
  end

  def self.unreporting_nodes(min_time=2.hours.ago, max_time=1.hour.ago)
    Node.reporting_nodes(min_time, max_time) - Node.reporting_nodes(max_time)
  end

  def last_report
    reports.order("created_at desc").limit(1).first
  end

  def self.group_by_execution
    success, failure = Node.reporting_nodes.to_a.partition(&:last_run_success?)
    breakdown_proc = proc { |x| x.last_report.resources.map(&:resource).sort } 
    failure_breakdown = failure.group_by(&breakdown_proc)
    success_breakdown = success.group_by(&breakdown_proc)
    return { "success" => success_breakdown, "failure" => failure_breakdown }
  end
end
