#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class AlterPermission < ActiveRecord::Migration

  def self.up
    change_column :permissions, :name, :string, :null => false
  end

  def self.down
    #pas de down
  end
end
