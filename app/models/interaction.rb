#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Interaction < ActiveRecord::Base
  belongs_to :logiciel
  belongs_to :ingenieur
  has_one :reversement

end
