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

    node_id = db.insert_report(report)

    db[:nodes].filter(:id => node_id)
  end
end
