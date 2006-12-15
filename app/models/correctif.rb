#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Correctif < ActiveRecord::Base
  has_many :binaires, :dependent => :destroy
  has_many :demandes
  has_many :reversements, :dependent => :destroy

  has_and_belongs_to_many :paquets

  file_column :patch

  validates_length_of :nom, :within => 3..25


  def updated_on_formatted
    d = @attributes['updated_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end

  def created_on_formatted
    d = @attributes['created_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end


  def mes_demandes(beneficiaire)
    if beneficiaire
      demandes.find_all_by_beneficiaire_id(beneficiaire.client.beneficiaires)
    else
      demandes
    end
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }     
  end
end
