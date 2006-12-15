#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module IngenieursHelper

  def link_to_ingenieurs
    link_to 'Ing�nieurs', :action => 'list', :controller => 'ingenieurs'
  end

  def link_to_ingenieur(inge)
    link_to(inge.identifiant.nom, :action => 'show', 
            :controller => 'ingenieurs', :id => inge)
  end
end
