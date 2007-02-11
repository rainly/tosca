#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'changelogs_controller'

# Re-raise errors caught by the controller.
class ChangelogsController; def rescue_action(e) raise e end; end

class ChangelogsControllerTest < Test::Unit::TestCase
  fixtures :changelogs

  def setup
    @controller = ChangelogsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:changelogs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:changelog)
    assert assigns(:changelog).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:changelog)
  end

  def test_create
    num_changelogs = Changelog.count

    post :create, :changelog => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_changelogs + 1, Changelog.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:changelog)
    assert assigns(:changelog).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Changelog.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Changelog.find(1)
    }
  end
end
