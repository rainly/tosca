#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Fournisseur < ActiveRecord::Base
  has_many :paquets
end
