class CreateSettings < ActiveRecord::Migration

  def self.up
    create_table :settings, :force => true do |t|
      t.string :name, :limit => 30, :default => "", :null => false
      t.text :value
      t.column :updated_on, :timestamp
    end
  end

  def self.down
    drop_table :settings
  end

end
