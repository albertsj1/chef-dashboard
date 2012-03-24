require 'db'
require 'tempfile'
require 'fileutils'

def create_db
  file = Tempfile.new('chef-dashboard')
  db = Chef::Dashboard::DB.new("sqlite://#{file.path}")
  db.create_schema
  return db, file.path
end

require 'minitest/autorun'
