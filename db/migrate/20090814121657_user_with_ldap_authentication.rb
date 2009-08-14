class UserWithLdapAuthentication < ActiveRecord::Migration

  def self.up
    remove_column :users, :informations
    add_column :users, :updated_on, :timestamp, :null => false
    add_column :users, :ldap, :boolean, :default => false, :null => false
  end

  def self.down
    add_column :users, :informations, :text
    remove_column :users, :updated_on
    remove_column :users, :ldap
  end

end
