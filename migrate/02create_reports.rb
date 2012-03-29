class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.primary_key :id
      t.integer :node_id, :null => false
      t.timestamp :created_at, :null => false
      t.boolean :success, :null => false, :default => false
    end

    add_index :reports, [:node_id, :created_at]
  end

  def self.down
    drop_table :reports
  end
end
