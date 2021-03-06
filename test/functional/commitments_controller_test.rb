#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require File.dirname(__FILE__) + '/../test_helper'
require 'commitments_controller'

# Re-raise errors caught by the controller.
class CommitmentsController; def rescue_action(e) raise e end; end

class CommitmentsControllerTest < ActionController::TestCase
  fixtures :commitments, :issuetypes, :severities

  def setup
    @controller = CommitmentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login 'admin', 'admin'
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:commitments)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:commitment)
    assert assigns(:commitment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:commitment)
  end

  def test_create
    num_commitments = Commitment.count

    post :create, :commitment => {
      :correction => 11,
      :workaround => 0.16 # 0.16 stands for 4 hours
    }

    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_equal num_commitments + 1, Commitment.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:commitment)
    assert assigns(:commitment).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_destroy
    assert_not_nil Commitment.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Commitment.find(1)
    }
  end
end
