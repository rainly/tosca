#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Etatreversement < ActiveRecord::Base
  has_many :reversements #, :dependent => :destroy
  #has_many :correctifs, :through => :reversements

end
