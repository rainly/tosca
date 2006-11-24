#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class CreateEtatreversements < ActiveRecord::Migration
  def self.up
    # les �tats possibles d'un reversement
    create_table :etatreversements do |t|
      t.column :nom, :string, :null => false
      t.column :description, :text, :null => false
    end

    # un reversement a maintenant un �tat ^_^'
    add_column :reversements, :etatreversement_id, :integer, :null => false

  end

  def self.down
    drop_table :etatreversements
    remove_column :reversements, :etatreversement_id
  end
end
