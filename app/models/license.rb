#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class License < ActiveRecord::Base
  has_many :logiciels
end
