#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Severite < ActiveRecord::Base
  has_many :demandes
  has_many :engagements
end
