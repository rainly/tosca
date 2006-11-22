#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class CreateCorrectionsCorrectifs < ActiveRecord::Migration
  def self.up
    #Quand on ne met pas l'id � false, ca cr�e une colonne id auto-incr�ment�
    create_table :correctifs_demandes, :id => false do |table|
      table.column :correctif_id, :integer, :null => false
      table.column :demande_id, :integer, :null => false
    end

    add_index :correctifs_demandes, :correctif_id
    add_index :correctifs_demandes, :demande_id
  end

  def self.down
    drop_table :correctifs_demandes
  end
end
