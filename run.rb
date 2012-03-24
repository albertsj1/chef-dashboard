require 'sinatra'

set :haml, :layout => :application_layout

get '/' do
  haml :index
end
