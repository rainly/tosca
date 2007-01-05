#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Beneficiaire < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  belongs_to :client, :counter_cache => true

  has_and_belongs_to_many :projets

  #TODO : revoir la hi�rarchie avec un nested tree (!)
  belongs_to :beneficiaire
  has_many :demandes, :dependent => :destroy

  def nom
    return identifiant.nom if identifiant
  end


  def contrat_ids
    @cache ||=  Contrat.find(:all, :select => 'id', 
                             :conditions => ['client_id=?', self.client_id]).collect{|c| c.id}
  end

  alias_method :to_s, :nom
end
