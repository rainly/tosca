#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Bouquet < ActiveRecord::Base
  has_many :classifications
end
