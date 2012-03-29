require 'sinatra'
require 'yajl'

require 'dashboard'
require 'db'

$db = Chef::Dashboard::DB.new({ :adapter => "sqlite3", :database => "dashboard.db" })

set :haml, :layout => :application_layout

get '/' do
  @nodes = Node.reporting_nodes.all #FIXME remove $nodes
  @success, @failure = @nodes.partition(&:last_run_success?)
  @last_node = @nodes.sort_by { |x| x.last_report.created_at }.last
  @groups = Node.group_by_execution

  @failure_groups = @groups["failure"].sort_by { |k,v| v.count }.reverse
  @success_groups = @groups["success"].sort_by { |k,v| v.count }.reverse

  haml :index
end

get '/nodes' do
  haml :nodes
end

put '/report' do
  Node.create_report(Yajl.load(request.body.read))
  return 200
end
