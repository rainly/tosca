#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return "N/A" unless binaire
    nom = binaire.nom
    link_to nom, :controller => 'binaires', :action => 'show', :id => binaire
  end

  
end
