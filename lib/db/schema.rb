require 'db'

module Chef::Dashboard::DB::Schema
  class << self

    def create(db)
      create_nodes(db)
      create_status(db)
      create_reports(db)
      create_report_resources(db)
    end

    def create_nodes(db)
      db.create_table('nodes') do
        primary_key 'id'
        String 'name', :index => true
        String 'fqdn', :index => true
        String 'ipaddress', :index => true
      end
    end

    def create_status(db)
      db.create_table('status') do
        primary_key 'id'
        Integer 'node_id', :index => true
        TrueClass 'success'
        index %w[node_id success]
      end
    end

    def create_reports(db)
      db.create_table('reports') do
        primary_key 'id'
        Integer 'node_id', :index => true
        DateTime 'created_at'
        index %w[node_id created_at]
      end
    end

    def create_report_resources(db)
      db.create_table('report_resources') do
        primary_key 'id'
        Integer 'report_id', :index => true
        String 'resource', :index => true
        index %w[report_id resource]
      end
    end

  end 
end
