class CreateReportResources < ActiveRecord::Migration
  def self.up
    create_table :report_resources do |t|
      t.primary_key :id
      t.integer :report_id, :null => false
      t.string :resource, :null => false
    end

    add_index :report_resources, [:report_id, :resource], :unique => true
  end

  def self.down
    drop_table :report_resources
  end
end
