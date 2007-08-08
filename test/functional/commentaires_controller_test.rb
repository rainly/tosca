#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'commentaires_controller'

# Re-raise errors caught by the controller.
class CommentairesController; def rescue_action(e) raise e end; end

class CommentairesControllerTest < Test::Unit::TestCase
  fixtures :commentaires, :demandes, :beneficiaires

  def setup
    @controller = CommentairesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'bob', 'test'
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
    post :update, { :id => 1,
      :commentaire => {
        :demande_id => 3,
        :identifiant_id => 1,
        :piecejointe_id => 1,
        :corps => 'Voici un autre commentaire',
        :prive => 1,
        :created_on => '2006-09-21 08:19:30',
        :updated_on => '2007-07-12 14:21:17',
        :severite_id => 2,
        :statut_id => 7,
        :ingenieur_id => 1
      }
    }

    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Commentaire.find(1)

    post :destroy, :id => 1
    
    assert flash.has_key?(:notice)
    assert_response :redirect
    assert_redirected_to :action => 'comment'

    assert_raise(ActiveRecord::RecordNotFound) {
      Commentaire.find(1)
    }
  end
end
