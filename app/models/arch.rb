#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Arch < ActiveRecord::Base
  has_many :paquets
end
