#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Socle < ActiveRecord::Base
  has_one :machine
  has_many :paquets
  has_many :demandes
end
