#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'

# Each Controller Test should test all _public_ methods
class AccountControllerTest < ActionController::TestCase
  fixtures :users, :roles, :permissions_roles, :permissions, :clients,
    :contrats_users, :contrats, :images, :beneficiaires, :credits,
    :components, :clients, :ingenieurs

  def test_login_and_logout
    %w(admin manager expert customer viewer).each { |l|
      login l, l
      assert_response :redirect
      # strange initialisation bug with bienvenue_path
      assert_redirected_to({:action => "index", :controller => "bienvenue"})
      assert session[:user] == User.find_by_login(l)

      logout
      assert_redirected_to '/'
      assert session[:user].nil?
    }
  end

  def test_new
    %w(admin manager).each { |l|
      login l, l
      get :new
      assert_response :redirect
      assert_redirected_to signup_new_account_path
      # TODO : test ajax things. See demandes_controller_test if you need sample
    }
  end

  def test_signup_recipient
    login 'manager', 'manager'
    get :signup
    form = select_form 'main_form'
    # 3 fields are mandatory
    form.user.name = "Recipient"
    form.user.email = App::MaintenerEmail
    form.user.login = "recipient"
    form.user.contrat_ids.value = "1"
    form.submit

    user = assigns(:user)
    assert_not_nil user.beneficiaire
    assert_redirected_to account_path(user)
    assert flash.has_key?(:notice)
    assert !flash.has_key?(:warning)

    # Test login of the new account, freshly created
    login user.login, user.pwd
    assert_response :redirect
    assert_redirected_to bienvenue_path
    assert session[:user] == user
  end

  def test_signup_expert
    login 'manager', 'manager'
    get :signup
    form = select_form 'main_form'
    # 3 fields are mandatory
    form.user.name = "Engineer"
    form.user.email = App::MaintenerEmail
    form.user.login = "engineer"
    # field used to indicate that's an expert account
    form.user.client = "false"
    form.user.contrat_ids.value = "1"
    form.submit

    user = assigns(:user)
    assert_not_nil user.ingenieur
    assert_redirected_to account_path(user)
    assert flash.has_key?(:notice)
    assert !flash.has_key?(:warning)
    # Test login of the new account, freshly created
    login user.login, user.pwd
    assert_response :redirect
    assert_redirected_to bienvenue_path
    assert session[:user] == user
  end

  def test_show
    %w(admin manager expert customer viewer).each {  |l|
      login l, l
      get :show, :id => session[:user].id
      assert_response :success
      assert_template 'show'
      assert_not_nil assigns(:user)
    }
  end

  def test_index
    %w(admin manager expert customer).each { |l|
      login l, l
      get :index
      assert_response :success
      assert_template 'index'
      assert_not_nil assigns(:users)

      # We cannot user check_ajax_filters, since it's a distant field
      xhr :get, :index, :filters => { :client_id => 1 }
      assert_response :success
      assigns(:users).each { |u| assert_equal u.beneficiaire.client_id, 1 }

      xhr :get, :index, :filters => { :role_id => 1 }
      assert_response :success
      assigns(:users).each { |u| assert_equal u.role_id, 1 }

      xhr :get, :index, :filters => { :name => "customer" }
      assert_response :success
    }
  end

  def test_update
    %w(admin manager expert customer viewer).each { |l|
      login l, l
      get :edit, :id => session[:user].id
      assert_response :success
      assert_template 'edit'
      assert_not_nil assigns(:user)

      submit_with_name('user', 'I love thai girls')
      assert_response :redirect
      assert_redirected_to account_path(session[:user].id)
      assert_not_nil assigns(:user)
      assert assigns(:user).name ==  'I love thai girls'
    }
  end

  # It will be a feature for next version, so it's just a get test, for now
  def test_lemon
    login 'admin', 'admin'
    get :lemon
    assert_response :success
  end


  def test_become
    %w(admin manager).each { |l|
      login l, l
      post :become, :id => Beneficiaire.find(:first).id
      assert_response :redirect
      assert_redirected_to bienvenue_path
    }
  end

  def test_ajax_place
    login 'manager', 'manager'
    test = Proc.new do |params|
      xhr :get, :ajax_place, params
      assert_response :success
      assert_template 'ajax_place'
      assert_not_nil assigns(:user)
    end
    test.call(:client => 'true')
    assert_not_nil assigns(:user_recipient)
    test.call(:client => 'false')
    assert_not_nil assigns(:user_engineer)
  end


  def test_ajax_contracts
    login 'manager', 'manager'
    test = Proc.new do |params|
      xhr :get, :ajax_contracts, params
      assert_response :success
      assert_template 'ajax_contracts'
      assert_not_nil assigns(:contrats)
      assert_not_nil assigns(:user)
    end
    # test on a new user, without id
    test.call(:client_id => Client.find(:first).id)
    # test on an existing user, with his id
    test.call(:client_id => Client.find(:first).id,
              :id => User.find(:first).id)
  end

end
