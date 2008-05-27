require File.dirname(__FILE__) + '/../test_helper'
require 'paquets_controller'

# Re-raise errors caught by the controller.
class PaquetsController; def rescue_action(e) raise e end; end

class PaquetsControllerTest < Test::Unit::TestCase
  fixtures :paquets, :conteneurs, :distributeurs, :mainteneurs, :logiciels,
    :contrats, :clients, :credits, :components

  def setup
    @controller = PaquetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:paquets)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:paquet)
    assert assigns(:paquet).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:paquet)
  end

  def test_create
    num_paquets = Paquet.count

    post :create, :paquet => { :logiciel_id => 1,
           :conteneur_id => 1, :contrat_id => 1, :configuration => '' }

    assert_response :redirect
    assert_redirected_to logiciel_path(assigns(:paquet).logiciel)

    assert_equal num_paquets + 1, Paquet.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:paquet)
    assert assigns(:paquet).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => '1-openoffice-org'
  end

  def test_destroy
    assert_not_nil Paquet.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Paquet.find(1)
    }
  end
end
