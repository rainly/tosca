#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module CompetencesHelper

  def liste_competences(competences)
    competences.collect{|c| c.nom}.join(', ')
  end
end
