#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Etatreversement < ActiveRecord::Base
  has_many :correctifs
end
