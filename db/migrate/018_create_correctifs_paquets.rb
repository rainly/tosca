class CreateCorrectifsPaquets < ActiveRecord::Migration
  def self.up
    create_table :correctifs_paquets, :id => false do |t|
      t.column :correctif_id, :integer, :null => false
      t.column :paquet_id, :integer, :null => false
    end
    add_index :correctifs_paquets, :paquet_id
    add_index :correctifs_paquets, :correctif_id

    # modification des correctifs pour leur ind�pendances (!)
    add_column :correctifs, :id_mantis, :integer, :null => true

  end

  def self.down
    drop_table :correctifs_paquets
    remove_column :correctifs, :id_mantis
  end
end
