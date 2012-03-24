require 'sequel'
require 'dashboard'
require 'db/schema'

class Chef::Dashboard::DB 

  def initialize(dsn)
    Sequel::Model.db = Sequel.connect(dsn)
    require_models
  end

  def create_schema
    Schema.create(Sequel::Model.db)
  end

  def require_models
    models_files = "#{File.expand_path(File.dirname(__FILE__))}/db/models/*"
    Dir[models_files].each do |x|
      require x
    end
  end
end

__END__
      attr_reader :db

      def initialize(dsn)
        @db = Sequel.connect(dsn)
      end


      def insert_report(report)
        res, messages = Validator.validate_report(report)

        unless res
          raise ArgumentError, messages
        end

        node_id = db[:nodes].insert(
          :name       => report[:name],
          :fqdn       => report[:fqdn],
          :ipaddress  => report[:ipaddress]
        )

        report_id = db[:reports].insert(
          :node_id => node_id, 
          :success => true, 
          :created_at => DateTime.now
        )

        report[:resources].each do |resource|
          db[:report_resources].insert(
            :report_id => report_id, 
            :resource => resource
          )
        end

        return node_id
      end
    end
  end
end
