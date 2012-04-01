require 'sinatra'
require 'yajl'

require 'dashboard'
require 'db'

# FIXME configuration
$db = Chef::Dashboard::DB.new({ :adapter => "sqlite3", :database => "dashboard.db" })

set :haml, :layout => :application_layout

get '/' do
  @nodes = Node.reporting_nodes
  @success, @failure = @nodes.partition(&:last_run_success?)
  @last_node = Node.all.sort_by { |x| x.last_report.created_at }.last
  @groups = Node.group_by_execution

  @last_hour_unreporting = Node.reporting_nodes(2.hours.ago, 1.hour.ago)
  @last_six_unreporting = Node.reporting_nodes(6.hours.ago, 1.hour.ago)
  @last_day_unreporting = Node.reporting_nodes(1.day.ago, 1.hour.ago)

  @failure_groups = @groups["failure"].sort_by { |k,v| v.count }.reverse
  @success_groups = @groups["success"].sort_by { |k,v| v.count }.reverse

  haml :index
end

get '/nodes' do
  @nodes = Node.reporting_nodes

  if params["last_report_in_hours"]
    @reporting_nodes = Node.reporting_nodes(params["last_report_in_hours"].to_i.hours.ago, 0.hours.ago)
  else
    @reporting_nodes = @nodes
  end

  haml :nodes
end

put '/report' do
  Node.create_report(Yajl.load(request.body.read))
  response["Content-Type"] = "application/json"
  return Yajl.dump({ })
end
