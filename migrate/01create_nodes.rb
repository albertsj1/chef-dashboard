class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.primary_key :id
      t.string :name, :null => false
      t.string :fqdn, :null => false
      t.string :ipaddress, :null => false
    end
    add_index :nodes, [:name], :unique => true
    add_index :nodes, [:fqdn], :unique => true
    add_index :nodes, [:ipaddress]
  end

  def self.down
    drop_table :nodes
  end
end
