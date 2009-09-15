class MoveContext2Contract < ActiveRecord::Migration

  def self.up
    add_column :contracts, :context, :string
    remove_column :clients, :context
  end

  def self.down
    remove_column :contracts, :context
    add_column :clients, :context, :string
  end

end
