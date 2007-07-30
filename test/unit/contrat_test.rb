#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class ContratTest < Test::Unit::TestCase
  fixtures :contrats, :clients

  def test_ouverture_formatted
    c = Contrat.find 1
    c_empty = Contrat.find 4
    assert_equal c.ouverture_formatted, '26.10.2005'
    assert_equal c_empty.ouverture_formatted, '00.00.0000'
  end
  def test_cloture_formatted
    c = Contrat.find 1
    c_empty = Contrat.find 4
    assert_equal c.cloture_formatted, '27.10.2008'
    assert_equal c_empty.cloture_formatted, '00.00.0000'
  end
  def test_find_engagement
    #TODO when demande/commentaire will be refactored
  end
  def test_demandes
    #TODO idem
  end
  def test_typedemandes
    c = Contrat.find 1
    assert_equal c.typedemandes,[]
  end
  
  def test_to_s 
    c = Contrat.find 1
    c_empty = Contrat.find 4
    c_name_empty = Contrat.find 5
    assert_equal c.to_s, '1 - toto'
    assert_equal c_empty.to_s, '4 - unknown client'
    assert_equal c_name_empty.to_s, '5 - nil'
  end
end
