class ClientAccessCodeHelper < ActiveRecord::Migration
  class Client < ActiveRecord::Base
  end

  def self.up
    change_column :clients, :access_code, :string, :null => true
    add_column :clients, :access_code_helper, :string, :null => true
    Client.all.each do |c|
      code, helper = c.access_code.split(' ') if c.access_code
      c.update_attributes(:access_code => code, :access_code_helper => helper)
    end
  end

  def self.down
    remove_column :clients, :access_code_helper
  end
end
