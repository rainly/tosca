require File.dirname(__FILE__) + '/../test_helper'

class DemandeTest < Test::Unit::TestCase
  fixtures :demandes, :typedemandes, :severites, :statuts, :contracts,
    :recipients, :clients, :users, :versions, :commentaires,
    :contracts_users

  def test_to_strings
    check_strings Demande, :resume, :description, :full_software_name, :elapsed_formatted
  end

  def test_presence_of_attributes
    recipient = recipients(:recipient_00001)
    request = Demande.new({:description => 'description', :resume => 'resume',
        :recipient => recipient, :submitter => recipient.user,
        :statut => statuts(:statut_00001), :severite => severites(:severite_00001),
        :contract => recipient.user.contracts.first })
    # must have a recipient
    assert request.save

    # commentaire table must have things now ...
    c = Commentaire.find :first, :conditions => { :demande_id => request.id }
    assert_equal c.demande_id, request.id
    assert_equal c.severite, request.severite
    assert_equal c.statut, request.statut
    assert_equal c.ingenieur, request.ingenieur
  end

  def test_scope
    Demande.set_scope([Contract.find(:first).id])
    Demande.find(:all)
    Demande.remove_scope
  end

  def test_arrays
    check_arrays Demande, :remanent_fields
  end

  def test_fragments
    assert !Demande.find(:first).fragments.empty?
  end

  def test_finder
    request = demandes(:demande_00010)
    comment = request.find_status_comment_before(request.last_status_comment)
    assert_not_nil comment
  end

  def test_helpers_function
    Demande.find(:all).each { |r|
      r.time_running?
      result = r.state_at(Time.now)
      assert_instance_of Demande, result
      assert result.statut_id?
      assert result.ingenieur_id?
      assert result.severite_id?
      r.critical?
      assert_not_nil r.client
      assert_not_nil r.commitment 
      assert_instance_of Fixnum, r.interval
    }
  end

  def test_reset_elapsed
    Demande.find(:first).reset_elapsed
  end

  def test_set_defaults
    request = Demande.find(:first)
    request.statut_id = nil
    request.set_defaults(nil, request.recipient, {})
    request.set_defaults(request.ingenieur, nil, {})
  end

=begin
  TODO : rework with rule contract model
  def test_client
    r = Demande.find 1,2
    c = Client.find 1
    assert_equal r[0].client, c
    assert_equal r[1].client, c
  end

  def test_respect_contournement_and_correction
    r = Demande.find 3
    c = Contract.find 2
    assert_kind_of String, r.respect_contournement(c.id)
    assert_kind_of String, r.respect_correction(c.id)
  end

  # No test for affiche_temps_ecoule and affiche_temps_correction
  # because the display of the time may change
  def test_temps_correction
    r = Demande.find 3
    assert_operator r.temps_correction, '>=', 0
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
  def test_commitment
    r = Demande.find 3
    e = Commitment.find 1
    assert_equal r.commitment(3), e
  end
  def test_affiche_temps_ecoule
    r = Demande.find 3
    assert r.affiche_temps_ecoule
  end
=end

end
