require 'bundler/setup'
require 'minitest/unit'

require 'db'
require 'tempfile'
require 'fileutils'

class DashboardTestCase < MiniTest::Unit::TestCase
  def run(*args, &block)
    Sequel::Model.db.transaction(:rollback=>:always){super(*args, &block)}
  end
end

$db_file = Tempfile.new('chef-dashboard')
$db = Chef::Dashboard::DB.new("sqlite://#{$db_file.path}", false)
$db.create_schema
$db.require_models

require 'minitest/autorun'
