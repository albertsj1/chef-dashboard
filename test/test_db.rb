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
      "name" => "fart",
      "fqdn" => "fart.int.example.com",
      "ipaddress" => "127.0.0.1",
      "success" => true,
      "resources" => [
        "execute[I farted]"
      ]
    }

    node = Node.create_report(report_hash)
    assert(node)
    assert_equal(node.reports.count, 1)
    assert_equal(node.reports.first.resources.count, 1)

    node = Node[node.id]

    assert(node)
    assert_equal(node.reports.count, 1)
    assert_equal(node.reports.first.resources.count, 1)

    assert_raises(ArgumentError, "resources is not an Array") { Node.create_report({}) }
    assert_raises(ArgumentError, "report_hash is not a Hash") { Node.create_report(nil) }

    report_hash = {
      "name" => "fart",
      "fqdn" => "fart.int.example.com",
      "ipaddress" => "127.0.0.1",
      "resources" => []
    }

    assert_raises(Sequel::ValidationFailed) { Node.create_report(report_hash) }

    report_hash.delete(report_hash.keys.reject { |x| x == "resources" }.sample)
    assert_raises(Sequel::ValidationFailed) { Node.create_report(report_hash) }
    
    report_hash = {
      "name" => "fart",
      "fqdn" => "fart.int.example.com",
      "ipaddress" => "127.0.0.1",
      "success" => true
    }
    
    assert_raises(ArgumentError) { Node.create_report(report_hash) }

    # FIXME more tests for invalid data
  end
end
