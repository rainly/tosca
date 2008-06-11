require File.dirname(__FILE__) + '/../test_helper'
require 'phonecalls_controller'

# Re-raise errors caught by the controller.
class PhonecallsController; def rescue_action(e) raise e end; end

class PhonecallsControllerTest < Test::Unit::TestCase
  fixtures :phonecalls, :ingenieurs, :beneficiaires, :contracts, :users,
  :components, :credits, :clients

  def setup
    @controller = PhonecallsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    login 'admin', 'admin'
    @first_id = phonecalls(:phonecall_00001).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:phonecalls)
    # tests for the ajax filters :
    test_filter :ingenieur_id, 1
    test_filter :beneficiaire_id, 1
    test_filter :contract_id, 1

    get :index, :filters => { :after => '2006-03-01' }
    assert_response :success
    assigns(:phonecalls).each { |a| assert_operator a.start, '>', '2006-03-01'.to_time }

    get :index, :filters => { :before => '2007-08-01' }
    assert_response :success
    assigns(:phonecalls).each { |a| assert_operator a.end, '<', '2008-08-01'.to_time }

  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:phonecall)
    assert assigns(:phonecall)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:phonecall)
  end

  def test_create
    num_phonecalls = Phonecall.count

    post :create, :phonecall => {
      :start => '2006-03-16 22:41:00',
      :end => '2007-03-16 16:41:00',
      :ingenieur_id => 1,
      :contract_id => 1,
      :beneficiaire_id => 1
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_phonecalls + 1, Phonecall.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:phonecall)
    assert assigns(:phonecall)
  end

  def test_update
    post :update, { :id => @first_id,
      :phonecall => { :start => '2006-03-16 22:41:00',
      :end => '2007-03-16 16:41:00',
      :ingenieur_id => 1,
      :contract_id => 1,
      :beneficiaire_id => 1}
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to demande_path(assigns(:phonecall).demande)
  end

  def test_destroy
    assert_nothing_raised {
      Phonecall.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Phonecall.find(@first_id)
    }
  end
  private
  # test the ajax filters
  # example : test_filter :statut_id, 2
  def test_filter attribute, value
    get :index, :filters => { attribute => value }
    assert_response :success
    assigns(:phonecalls).each { |d| assert_equal d[attribute], value }
  end
end
