require 'sinatra'

class Chef
  module Dashboard
    VERSION = "1.2.3"
  end
end

set :haml, :layout => :application_layout

get '/' do
  haml :index
end
