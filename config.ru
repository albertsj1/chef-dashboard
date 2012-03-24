require 'bundler/setup'
$:.unshift File.expand_path('app')
$:.unshift File.expand_path('lib')
require 'app'

run Sinatra::Application
