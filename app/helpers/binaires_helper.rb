#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module BinairesHelper

  def link_to_binaire(binaire)
    return '-' unless binaire and binaire.paquet
    name = "#{binaire.name}-#{binaire.paquet.version}-#{binaire.paquet.release}"
    link_to name, binaire_path(binaire.id)
  end

  # Link to create a new url for a Logiciel
  def link_to_new_binaire(paquet_id)
    return '-' unless paquet_id
    options = new_binaire_path(:paquet_id => paquet_id)
    link_to(image_create(_('binary')), options, LinksHelper::NO_HOVER)
  end


end
