#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Groupe < ActiveRecord::Base
  has_many :classifications
end
