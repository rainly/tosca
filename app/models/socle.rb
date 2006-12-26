#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Socle < ActiveRecord::Base
  has_one :machine, :dependent => :destroy
  has_many :binaires
  has_many :paquet, :through => :binaires

  belongs_to :client # TODO :
  # Mettre des filtres (before_create||before_update) pour maintenir
  # la consistance entre la r�alit� des paquets.socle et la vision client.socle

  def to_s
    nom
  end
end
