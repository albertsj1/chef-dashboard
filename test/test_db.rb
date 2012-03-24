require 'helper'

class TestDB < TestHelper

  attr_reader :db

  def setup
    @db, @path = create_db
  end

  def teardown
    FileUtils.rm_f @path
  end

  def test_fart
    report_hash = {
      :name => "fart",
      :fqdn => "fart.int.example.com",
      :ipaddress => "127.0.0.1",
      :success => true,
      :resources => [
        "execute[I farted]"
      ]
    }

    db.transaction do
      node = Node.create(:name => report_hash[:name], :fqdn => report_hash[:fqdn], :ipaddress => report_hash[:ipaddress])
      report = node.add_report(Report.create(:success => true, :created_at => DateTime.now))
      report_hash[:resources].each do |resource|
        report.add_resource(Resource.create(:resource => resource))
      end
      node.save
      assert(node)
      assert_equal(node.reports.count, 1)
      assert_equal(report.resources.count, 1)
    end
  end
end
