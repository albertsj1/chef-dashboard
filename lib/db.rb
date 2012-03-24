require 'sequel'

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

    end
  end
end
