#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module InteractionsHelper
  # call it like : 
  # <%= link_to_interaction @interaction %>
  def link_to_interaction(i)
    return "N/A" unless i
    link_to i.resume, :controller => 'interactions', 
    :action => 'show', :id => i.id
  end

  
end
