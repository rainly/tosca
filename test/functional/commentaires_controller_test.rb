require File.dirname(__FILE__) + '/../test_helper'
require 'commentaires_controller'

# Re-raise errors caught by the controller.
class CommentairesController; def rescue_action(e) raise e end; end

# TODO : As of Rails 2.0.2, the "setup" method is broken
#
# When it will be possible, this one can migrate into ActionController::TestCase
# and validate within the test suite the _not_allowed? effect of the
# CommentaireController
class CommentairesControllerTest < Test::Unit::TestCase
  fixtures :commentaires, :demandes, :beneficiaires, :users,
  :permissions, :roles, :permissions_roles, :ingenieurs,
  :statuts, :clients, :credits, :components, :contracts, :contracts_users

  def setup
    @controller = CommentairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end


  def test_new
    get :new
    assert_response :success
    assert_template nil
  end

  def test_create
    get :create
    assert_response :success
    assert_template nil
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:commentaires)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:commentaire)
    assert assigns(:commentaire)
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:commentaire)
    assert assigns(:commentaire)
  end

  def test_update
    post :update, {
      :id => 1,
      :commentaire => {
        :demande_id => 1,
        :user_id => 2,
        :piecejointe_id => 1,
        :corps => 'Voici un autre commentaire',
        :prive => 0,
        :created_on => '2006-09-21 08:19:30',
        :updated_on => '2007-07-12 14:21:17',
        :severite_id => 1,
        :statut_id => 7,
        :ingenieur_id => 1
      }
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end


  # This test is one of the severe issue encountered in production
  # It was when a comment posted for cancellation of a request,
  # put back request in "saved" status.
  def test_comment
    old_statut_id = Demande.find(1).statut_id

    post(:comment, { :id => "2-une-autre-demandes",
      :commentaire => {
        "corps" => "promenons nous dans les bois",
        "prive" => "0",
        "ingenieur_id" => "",
        "severite_id" => "",
        "statut_id" => "3"
      },
      :mce_editor_0_formatSelect => "",
      :piecejointe => { "file_temp" => "", "file" => "" }
         })

    # TODO : why it's not a success ????
    assert_response :redirect
    assert_redirected_to(:controller => "demandes", :action => "show",
                         :id => "2-Copie-d-une-question-dans-OOo")

    assert(Demande.find(1).statut_id == old_statut_id)
  end

end
