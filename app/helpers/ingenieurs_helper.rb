#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module IngenieursHelper

  def link_to_ingenieurs
    link_to 'Ing�nieurs', :action => 'list', :controller => 'ingenieurs'
  end
end
