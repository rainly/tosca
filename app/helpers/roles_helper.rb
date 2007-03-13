#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module RolesHelper

  # used in account list
  # call it like this :
  # [<%= link_to_edit_role role %>]
  def link_to_edit_role(role)
    return '-' unless role
    link_to(role.nom, :controller => 'roles', :action => 'edit', :id => role)
  end
end
