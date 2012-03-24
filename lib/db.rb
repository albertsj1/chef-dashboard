require 'sequel'
require 'db/schema'
require 'db/validator'

class Chef
  module Dashboard
    class DB

      attr_reader :db

      def initialize(dsn)
        @db = Sequel.connect(dsn)
      end

      def create_schema
        Schema.create(db)
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
