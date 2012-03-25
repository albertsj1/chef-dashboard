require 'sequel'
require 'dashboard'
require 'db/schema'

class Chef::Dashboard::DB 

  attr_reader :db

  def initialize(dsn, do_require_models = true)
    Sequel.connect(dsn)
    @db = Sequel::Model.db 
    require_models if do_require_models
  end

  def create_schema
    Schema.create(@db)
  end

  def require_models
    models_files = "#{File.expand_path(File.dirname(__FILE__))}/db/models/*"
    Dir[models_files].each do |x|
      require x
    end
  end

  def transaction(&block)
    @db.transaction(&block)
  end

end
