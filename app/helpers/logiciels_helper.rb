#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module LogicielsHelper

  # Display a link to a Logiciel (software)
  def link_to_logiciel(logiciel)
    return '-' unless logiciel and logiciel.is_a? Logiciel
    link_to logiciel.nom, :action => 'show', :controller => 'logiciels', :id => logiciel
  end

  # Link to create a new url for a Logiciel
  def link_to_new_urllogiciel(logiciel_id)
    return '-' unless logiciel_id 
    link_to(image_create('une url'), :controller => 'urllogiciels', 
            :action => 'new', :logiciel_id => logiciel_id)
  end

end
