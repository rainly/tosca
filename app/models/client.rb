#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Client < ActiveRecord::Base
  belongs_to :photo
  has_many :beneficiaires
  has_many :interactions, :dependent => :destroy
  has_many :contrats, :dependent => :destroy, 
    :include => Contrat::INCLUDE, :order => Contrat::ORDER
  belongs_to :support
  has_many :classifications
  has_many :documents

  has_and_belongs_to_many :socles

  has_many :paquets, :through => :contrats, :include => Paquet::INCLUDE
  has_many :demandes, :through => :beneficiaires # , :source => :demandes
  has_many :binaires, :through => :paquets

  def ingenieurs
    return [] if contrats.empty?
    Ingenieur.find(:all,
                   :conditions => 'contrats_ingenieurs.contrat_id IN ' +
                     "(#{contrats.collect{|c| c.id}.join(',')})",
                   :joins => 'INNER JOIN contrats_ingenieurs ON ' +
                     'contrats_ingenieurs.ingenieur_id=ingenieurs.id',
                   :include => [:identifiant]
                   )
  end

  def logiciels
    return [] if contrats.empty?
    # Voici le hack pour permettre au client Linagora d'avoir tous les softs
    return Logiciel.find_all if self.id == 4 
    conditions = 'logiciels.id IN (SELECT DISTINCT paquets.logiciel_id FROM ' + 
      'paquets WHERE paquets.contrat_id IN (' + 
      contrats.collect{|c| c.id}.join(',') + '))'
    Logiciel.find(:all, :conditions => conditions, :order => 'logiciels.nom')
  end

  def correctifs
    return [] if demandes.empty?
    Correctif.find(:all, 
                   :conditions => "correctifs.id IN (" + 
                     "SELECT DISTINCT demandes.correctif_id FROM demandes " +
                     "WHERE demandes.beneficiaire_id IN (" +
                     beneficiaires.collect{|c| c.id}.join(',') + "))"
                   )
  end

  def typedemandes
    joins = 'INNER JOIN engagements ON engagements.typedemande_id = typedemandes.id '
    joins << 'INNER JOIN contrats_engagements ON engagements.id = contrats_engagements.engagement_id'
    conditions = [ 'contrats_engagements.contrat_id IN (' +
        'SELECT contrats.id FROM contrats WHERE contrats.client_id = ?)', id ]
    Typedemande.find(:all, 
                     :select => "DISTINCT typedemandes.*",
                     :conditions => conditions, 
                     :joins => joins)
  end

  # TODO : à revoir, on pourrait envisager de moduler les sévérités selon 
  # les type de demandes
  def severites
    Severite.find_all
  end

  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    nom
  end

end
