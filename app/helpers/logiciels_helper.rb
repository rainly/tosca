#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module LogicielsHelper
  def link_to_logiciel(l)
    link_to l.nom, :action => 'show', :controller => 'logiciels', :id => l
  end
end
