#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Competence < ActiveRecord::Base

  def to_s
    nom
  end
end
