#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Fichier < ActiveRecord::Base
  belongs_to :paquet, :counter_cache => true
end
