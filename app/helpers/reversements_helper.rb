#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module ReversementsHelper
  def link_to_reversement(reversement)
    if reversement.interaction
      display = reversement.interaction.resume 
    else 
      display = "le reversement est orphelin : il n'est pas li� � une interaction"
    end
    link_to display, :controller => 'reversements',
    :action => 'show', :id => reversement.id
  end
end
