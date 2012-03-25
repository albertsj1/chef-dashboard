require 'bundler/setup'
require 'minitest/unit'

require 'db'
require 'tempfile'
require 'fileutils'

class TestHelper < MiniTest::Unit::TestCase
  def create_db
    file = Tempfile.new('chef-dashboard')
    db = Chef::Dashboard::DB.new("sqlite://#{file.path}", false)
    db.create_schema
    db.require_models
    return db, file.path
  end
end

require 'minitest/autorun'
