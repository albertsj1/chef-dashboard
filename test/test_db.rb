require 'helper'

class TestDB < MiniTest::Unit::TestCase

  attr_reader :db

  def setup
    @db, @path = create_db
  end

  def teardown
    FileUtils.rm_f @path
  end

  def test_fart
    report = {
      :name => "fart",
      :fqdn => "fart.int.example.com",
      :ipaddress => "127.0.0.1",
      :success => true,
      :resources => [
        "execute[I farted]"
      ]
    }

    node_id = Node.insert(:name => report[:name], :fqdn => report[:fqdn], :ipaddress => report[:ipaddress])

    assert(Node[node_id])
  end
end
