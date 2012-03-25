require 'helper'

class TestDB < TestHelper

  attr_reader :db

  def setup
    @db, @path = create_db
  end

  def teardown
    FileUtils.rm_f @path
  end

  def test_report_create
    report_hash = {
      :name => "fart",
      :fqdn => "fart.int.example.com",
      :ipaddress => "127.0.0.1",
      :success => true,
      :resources => [
        "execute[I farted]"
      ]
    }

    @node_id = nil

    db.transaction do
      node = Node.create_report(report_hash)

      assert(node)
      assert_equal(node.reports.count, 1)
      assert_equal(node.reports.first.resources.count, 1)

      @node_id = node.id
    end

    node = Node[@node_id]

    assert(node)
    assert_equal(node.reports.count, 1)
    assert_equal(node.reports.first.resources.count, 1)
  end
end
