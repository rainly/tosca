class AlterSupport < ActiveRecord::Migration
  def self.u
    change_column :supports, :maintenance, :boolean
    change_column :supports, :veille_technologique, :boolean
    change_column :supports, :assistance_tel, :boolean
    add_column :supports, :newsletter, :boolean
  end

  def self.down
    remove_column :supports, :newsletter, :boolean
    # Les 3 autres colonnes �taient des enum('OUI','NON')
    # Une erreur de jeunesse :)
  end
end
