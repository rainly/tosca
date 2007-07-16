#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return 'N/A' unless binaire and binaire.paquet
    nom = "#{binaire.nom}-#{binaire.paquet.version}-#{binaire.paquet.release}"
    link_to nom, :controller => 'binaires', :action => 'show', :id => binaire.id
  end

  def process_l(l)
    if l.nil?
      return ["unknown name","unknown id"]
    else
      return [l.to_s, l.id]
    end
  end

end
