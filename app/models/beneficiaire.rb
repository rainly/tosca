#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  belongs_to :client

  has_and_belongs_to_many :projets

  #TODO : revoir la hi�rarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy
  

  def nom
    return identifiant.nom if identifiant
  end


  def contrat_ids
    return client.contrats.collect{|c| c.id}.join(',')
  end

  alias_method :to_s, :nom
end
