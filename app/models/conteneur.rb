#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Conteneur < ActiveRecord::Base
  has_many :paquets
end
