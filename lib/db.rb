require 'active_record'
require 'active_support'
require 'dashboard'

class Chef::Dashboard::DB 

  attr_reader :db

  def initialize(dsn, do_require_models = true)
    ActiveRecord::Base.establish_connection(dsn)
    require_models if do_require_models
  end

  #--
  # This needs to be more of a migration system and less of a "slam the latest schema into the database" system.
  #++
  def migrate(quiet=false)
    migrate_files = "#{File.dirname(File.expand_path(__FILE__))}/../migrate/*.rb"
    Dir[migrate_files].sort.each do |x|
      require x
      obj = File.basename(x).sub(/^\d+/, '').sub(/\.rb$/, '').camelize.constantize.new
      if quiet
        obj.suppress_messages { obj.up }
      else
        obj.up
      end
    end
  end

  def require_models
    models_files = "#{File.expand_path(File.dirname(__FILE__))}/db/models/*"
    Dir[models_files].each do |x|
      require x
    end
  end

end
