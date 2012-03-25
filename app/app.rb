require 'sinatra'
require 'yajl'

require 'dashboard'
require 'db'

$db = Chef::Dashboard::DB.new("sqlite://dashboard.db")

set :haml, :layout => :application_layout

get '/' do
  haml :index
end

get '/nodes' do
  haml :nodes
end

put '/report' do
  Node.create_report(Yajl.load(request.body.read))
  return 200
end
