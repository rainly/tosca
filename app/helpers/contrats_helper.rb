#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module ContratsHelper

  # Cette m�thode n�cessite un :include => [:client] pour
  # fonctionner correctement
  def link_to_contrat(c)
    return "N/A" unless c
    link_to c.client.nom, :controller => 'contrats', 
    :action => 'show', :id => c
  end
end
