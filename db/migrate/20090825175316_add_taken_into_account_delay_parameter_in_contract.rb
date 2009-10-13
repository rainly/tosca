class AddTakenIntoAccountDelayParameterInContract < ActiveRecord::Migration

  class Contract < ActiveRecord::Base
  end

  def self.up
    add_column :contracts, :taken_into_account_delay, :integer, :default => 0, :null => false
    Contract.all.each { |c| c.update_attribute :taken_into_account_delay, 1 }
  end

  def self.down
    remove_column :contracts, :taken_into_account_delay
  end

end
