#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'engagements_controller'

# Re-raise errors caught by the controller.
class EngagementsController; def rescue_action(e) raise e end; end

class EngagementsControllerTest < Test::Unit::TestCase
  fixtures :engagements, :typedemandes, :severites

  def setup
    @controller = EngagementsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:engagements)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:engagement)
    assert assigns(:engagement).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:engagement)
  end

  def test_create
    num_engagements = Engagement.count

    post :create, :engagement => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_engagements + 1, Engagement.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:engagement)
    assert assigns(:engagement).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_not_nil Engagement.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Engagement.find(1)
    }
  end
end
