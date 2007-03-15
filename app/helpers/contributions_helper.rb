#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ContributionsHelper

  # call it like : link_to_typedocument t 
  def link_to_contribution_logiciel(logiciel)
    return '-' unless logiciel 
    link_to logiciel.nom + ' (' + logiciel.contributions.size.to_s + ')', {
      :action => 'list', :id => logiciel.id }
  end

  # call it like : 
  # <%= link_to_contribution @contribution %>
  def link_to_contribution(c)
    return '-' unless c
    link_to c.nom, :controller => 'contributions', :action => 'show', :id => c
  end

  
  def link_to_all_contributions
    link_to 'Voir toutes les contributions', :action => 'list', :id => 'all'
  end

end
