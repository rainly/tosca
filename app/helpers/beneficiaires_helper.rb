#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
module BeneficiairesHelper

  def link_to_beneficiaires
    link_to 'B�n�ficiaires', :action => 'list', :controller => 'beneficiaires'
  end
end
