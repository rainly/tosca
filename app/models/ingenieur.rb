#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Ingenieur < ActiveRecord::Base
  belongs_to :identifiant, :dependent => :destroy
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :contrats
  has_many :demandes
  has_many :interactions

  def self.ingenieur?(identifiant)
    Ingenieur.find_by_identifiant_id(identifiant.id).nil?
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on|chef_de_projet|expert_ossa)$/ || c.name == inheritance_column }       
  end


  def self.find_ossa(*args)
    conditions = ['ingenieurs.expert_ossa == ?', 1 ]
    Ingenieur.with_scope({:find => {:conditions => conditions }}) { yield }
  end

  def self.find_presta(*args)
    conditions = ['ingenieurs.expert_ossa == ?', 0 ]
    Ingenieur.with_scope({:find => {:conditions => conditions }}) { yield }
  end

  def nom
    identifiant.nom
  end
end
