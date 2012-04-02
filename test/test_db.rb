require 'helper'
require 'db'
require 'tempfile'
require 'fileutils'

class TestDB < MiniTest::Unit::TestCase

  def setup
    $db_file = Tempfile.new('chef-dashboard')
    $db = Chef::Dashboard::DB.new({ :adapter => "sqlite3", :database => $db_file.path }, false)
    $db.migrate(true)
    $db.require_models
  end

  def teardown
    FileUtils.rm_f $db_file
  end

  def get_report_hash
    report_hash = {
      "name" => "fart",
      "fqdn" => "fart.int.example.com",
      "ipaddress" => "127.0.0.1",
      "success" => true,
      "resources" => [
        "execute[I farted]"
      ]
    }
  end

  def test_group_by_execution
    report_hash = get_report_hash 
    Node.create_report(report_hash)

    %w[poop foo].each do |x|
      report_hash["name"] = x
      report_hash["fqdn"] = "#{x}.int.example.com"
      Node.create_report(report_hash)
    end

    %w[bar baz quux].each do |x|
      report_hash["name"] = x
      report_hash["fqdn"] = "#{x}.int.example.com"
      report_hash["success"] = false
      Node.create_report(report_hash)
    end

    breakdown = Node.group_by_execution

    assert_equal(breakdown["success"][["execute[I farted]"]].map(&:name).sort, %w[fart foo poop])
    assert_equal(breakdown["failure"][["execute[I farted]"]].map(&:name).sort, %w[bar baz quux])

    %w[bar quux].each do |x|
      report_hash["name"] = x
      report_hash["fqdn"] = "#{x}.int.example.com"
      report_hash["success"] = false
      report_hash["resources"] = [
        "execute[I farted]",
        "bash[shiiiit]"
      ]

      Node.create_report(report_hash)
    end

    breakdown = Node.group_by_execution

    assert_equal(breakdown["success"][["execute[I farted]"]].map(&:name).sort, %w[fart foo poop])
    assert_equal(breakdown["failure"][["execute[I farted]"]].map(&:name).sort, %w[baz])
    assert_equal(breakdown["failure"][["bash[shiiiit]", "execute[I farted]"]].map(&:name).sort, %w[bar quux])
  end

  def test_reporting_nodes
    report_hash = get_report_hash

    node = Node.create_report(report_hash)

    report_hash["name"] = "poop"
    report_hash["fqdn"] = "poop.int.example.com"

    node2 = Node.create_report(report_hash)

    assert_equal(Node.reporting_nodes.count, 2)

    node2.reports.last.update_attributes(:created_at => DateTime.now - 4000)

    assert_equal(Node.reporting_nodes.count, 1)
  end

  def test_last_run_success
    report_hash = get_report_hash

    node = Node.create_report(report_hash)
    assert(node.last_run_success?)

    node = Node.create_report(report_hash)
    assert(node.last_run_success? == true) # as opposed to ... Array

    report_hash["success"] = false

    node = Node.create_report(report_hash)
    assert(!node.last_run_success?)
  end

  def test_report_create
    report_hash = get_report_hash

    node = Node.create_report(report_hash)
    assert(node)
    assert_equal(node.reports.count, 1)
    assert_equal(node.reports.first.resources.count, 1)

    node = Node.find(node.id)

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

    assert_raises(ActiveRecord::RecordInvalid) { Node.create_report(report_hash) }

    # remove a random key (other than the resources array because that is
    # checked differently) from the report hash
    report_hash.delete(report_hash.keys.reject { |x| x == "resources" }.sample)

    assert_raises(ActiveRecord::RecordInvalid) { Node.create_report(report_hash) }
    
    report_hash = {
      "name" => "fart",
      "fqdn" => "fart.int.example.com",
      "ipaddress" => "127.0.0.1",
      "success" => true
    }
    
    assert_raises(ArgumentError) { Node.create_report(report_hash) }
  end

  def test_unreporting_nodes
    report_hash = get_report_hash
    node = Node.create_report(report_hash, 7.hours.ago)

    assert_equal(Node.unreporting_nodes(24.hours.ago, 6.hours.ago).to_a.count, 1)
    refute_equal(Node.unreporting_nodes(2.hours.ago, 1.hours.ago).to_a.count, 1)
    refute_equal(Node.reporting_nodes.to_a.count, 1)
  end

end
