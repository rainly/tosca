require File.dirname(__FILE__) + '/../test_helper'
require 'permissions_controller'

# Re-raise errors caught by the controller.
class PermissionsController; def rescue_action(e) raise e end; end

class PermissionsControllerTest < Test::Unit::TestCase
  fixtures :permissions

  def setup
    @controller = PermissionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:permissions)
  end

  def test_show
    get :show, :id => Permission.find(:first).id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:permission)
    assert assigns(:permission).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:permission)
  end

  def test_create
    num_permissions = Permission.count

    post :create, :permission => {}

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_permissions + 1, Permission.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:permission)
    assert assigns(:permission).valid?
  end

  def test_update
    post :update, :id => Permission.find(:first).id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_not_nil Permission.find(1)

    post :destroy, :id => Permission.find(:first).id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Permission.find(1)
    }
  end
end
