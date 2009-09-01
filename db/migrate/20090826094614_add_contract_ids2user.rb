class AddContractIds2user < ActiveRecord::Migration

  def self.up
    add_column :users, :contract_ids, :string
    User.all.each do |u|
      u.update_attribute(:contract_ids, u.contracts.uniq.collect(&:id))
    end
  end

  def self.down
    remove_column :users, :contract_ids
  end
end
