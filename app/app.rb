require 'sinatra'
require 'dashboard'

set :haml, :layout => :application_layout

get '/' do
  haml :index
end

post '/report' do
end
