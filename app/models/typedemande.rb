#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Typedemande < ActiveRecord::Base
  has_many :engagements
  has_many :demandes
end
