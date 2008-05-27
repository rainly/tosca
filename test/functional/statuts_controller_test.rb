require File.dirname(__FILE__) + '/../test_helper'
require 'statuts_controller'

# Re-raise errors caught by the controller.
class StatutsController; def rescue_action(e) raise e end; end

class StatutsControllerTest < Test::Unit::TestCase
  fixtures :statuts

  def setup
    @controller = StatutsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:statuts)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:statut)
    assert assigns(:statut).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:statut)
  end

  def test_create
    num_statuts = Statut.count

    post :create, :statut => { :name => "annihilated", :description => "apocalypse"}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_statuts + 1, Statut.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:statut)
    assert assigns(:statut).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Statut.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Statut.find(1)
    }
  end
end
