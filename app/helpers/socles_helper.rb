#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module SoclesHelper

  # call it like : 
  # <%= link_to_socle @socle %>
  def link_to_socle(c)
    return "N/A" unless c
    link_to c.nom, :controller => 'socles', 
    :action => 'show', :id => c
  end

end
