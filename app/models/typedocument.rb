#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Typedocument < ActiveRecord::Base
  has_many :documents
end
