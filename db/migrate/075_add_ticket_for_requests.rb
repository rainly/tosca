class AddTicketForRequests < ActiveRecord::Migration
  def self.up
    add_column :demandes, :temps_ecoule, :integer
    add_column :commentaires, :temps_ecoule, :integer

    #For single table inherance
    add_column :contrats, :type, :string

    add_column :contrats, :tickets_total,     :integer, :default => 0
    add_column :contrats, :tickets_consommes, :integer, :default => 0
    add_column :contrats, :ticket_temps,      :float, :default => 15

    Contrat.find(:all).each do |c|
      c.support? ? c[:type] = "ContratSupport" : c[:type] = "ContratOssa"
      c.save
    end
    remove_column :contrats, :support
  end

  def self.down
    add_column :contrats, :support, :boolean, :default => false
    remove_column :demandes, :temps_ecoule
    remove_column :commentaires, :temps_ecoule
    remove_column :contrats, :type
    remove_column :contrats, :tickets_total
    remove_column :contrats, :tickets_consommes
    remove_column :contrats, :ticket_temps
  end
end