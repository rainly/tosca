#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Urllogiciel < ActiveRecord::Base
  belongs_to :typeurl
  belongs_to :logiciel
end

