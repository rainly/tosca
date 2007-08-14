require File.dirname(__FILE__) + '/../test_helper'
require 'demandes_controller'

# Re-raise errors caught by the controller.
class DemandesController; def rescue_action(e) raise e end; end
class DemandesControllerTest < Test::Unit::TestCase
 
  fixtures :demandes, :commentaires, :demandes_paquets, 
    :beneficiaires, :clients, :statuts, :ingenieurs, :severites,
    :logiciels, :socles, :clients_socles, :paquets, :permissions, :roles, 
    :permissions_roles, :contrats, :contrats_engagements, :engagements, 
    :contrats_ingenieurs, :identifiants, :identifiants_roles, :piecejointes,
    :jourferies, :binaires, :binaires_demandes, :supports, :typedemandes


  def setup
    @controller = DemandesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
    @first_id = demandes(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:demandes)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'comment'

    assert_not_nil assigns(:demande)
    assert assigns(:demande).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:demande)
  end

  def test_create
    num_demandes = Demande.count

    post :create, :demande => {
      :resume => 'le résumé',
      :description => 'une description',
      :beneficiaire_id => 1,
      :statut_id => 1,
      :severite_id => 1
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_demandes + 1, Demande.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:demande)
    assert assigns(:demande).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'comment', :id => '1-Patch-Binaire'
  end

  def test_destroy
    assert_nothing_raised {
      Demande.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Demande.find(@first_id)
    }
  end
end
