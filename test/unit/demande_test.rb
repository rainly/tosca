#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

class DemandeTest < Test::Unit::TestCase
  fixtures :demandes, :typedemandes, :severites, :statuts, :supports,
    :beneficiaires, :clients, :identifiants,
    :paquets

  def test_presence_of_attributes
    request = Demande.new
    assert !request.save

    #length of the resume : 3..60
    request.resume = 'gg'
    assert !request.save
    request.resume = 'ddfkljmdfklmdjsfl kjfml skfjmlsdkjmflqsdkjfmldmfjqlkdjmflskfjmlqskd fmjskdmfjqmsldkfjm'
    assert !request.save
    request.resume ='resume'

    # must have a recipient
    assert !request.save
    request.beneficiaire = Beneficiaire.find 1
    # must have a description
    assert !request.save
    request.description = 'hello request'
    # must have a status and a severity != 0
    assert !request.save
    request.statut = Statut.find 1
    request.severite = Severite.find 1

    assert request.save

    # commentaire table must have things now ...
    c = Commentaire.find :first, :conditions => { :demande_id => request.id }
    assert_equal c.demande_id, request.id
    assert_equal c.corps, request.description
    assert_equal c.severite, request.severite
    assert_equal c.statut, request.statut
    assert_equal c.ingenieur, request.ingenieur
  end

  def test_to_param
    r = Demande.find 1
    assert_equal r.to_param, '1-Patch-Binaire'
  end
  def test_to_s
    r = Demande.find 1
    assert_equal r.to_s, "Anomalie (Bloquante) : Il faut trouver un moyen de patcher binairement OOo.\r<br/>\r<br/>Pour ce faire, voir les posts sur le sujet dans la mailing liste OOo, plus les outils qu'utilisent les jeux videos, qui sont au point sur le sujet.\r<br/>"
  end
  def test_created_and_updated_on_formatted
    r = Demande.find 1
    assert_equal r.updated_on_formatted, '12.07.2007 14:21'
    assert_equal r.created_on_formatted, '21.09.2006 08:19'
  end
  def test_client
    r = Demande.find 1,2
    c = Client.find 2
    assert_nil r[0].client
    assert_equal r[1].client, c
  end
  def test_respect_contournement_and_correction
    r = Demande.find 3
    c = Contrat.find 2
    assert_equal r.respect_contournement(c.id),
      '<p style="color: green">2 heures ouvrées</p>'
    assert_equal r.respect_correction(c.id), 
      '<p style="color: green">11 jours ouvrés</p>'
  end
  def test_affiche_temps_correction_and_contournement
    r = Demande.find 3
    assert_equal r.affiche_temps_correction, '-'
    assert_equal r.affiche_temps_contournement, '-'
  end
  def test_temps_correction
    r = Demande.find 3
    assert_equal r.temps_correction, 0
    assert_equal r.temps_contournement, 0
  end
  def test_delais_correction
    r = Demande.find 3
    assert_equal r.delais_correction, 475200.0
  end
  def test_temps_rappel
    r = Demande.find 3
    assert_equal r.temps_rappel, 0
    assert_equal r.affiche_temps_rappel, '-'
  end
  def test_engagement
    r = Demande.find 3
    e = Engagement.find 1
    assert_equal r.engagement(3), e
  end
  def test_affiche_temps_ecoule
    r = Demande.find 3
    assert_equal r.affiche_temps_ecoule, '-'
  end

end
