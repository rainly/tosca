#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class RenameRole < ActiveRecord::Migration
  def self.up
    rename_column :roles, :name, :nom
  end

  def self.down
    rename_column :roles, :nom, :name
  end
end
