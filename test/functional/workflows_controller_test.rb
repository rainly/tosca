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
require 'test_helper'

class WorkflowsControllerTest < ActionController::TestCase
  def setup
    login 'admin', 'admin'
  end

  def test_should_create_workflow
    workflow = Workflow.find(:first)
    workflow.destroy

    get :new, :issuetype_id => workflow.issuetype_id
    assert_response :success

    form = select_form 'new_workflow'
    form.workflow.allowed_status_ids = workflow.allowed_status_ids
    form.submit

    assert_response :redirect
    assert_redirected_to issuetype_path(workflow.issuetype)
    workflow.save!
  end

  def test_should_show_workflow
    get :show, :id => 1
    assert_response :success
    assert_template nil
  end

  def test_should_get_edit
    get :edit, :id => Workflow.first.id
    assert_response :success
    # TODO : test update
  end

  def test_should_update_workflow
=begin
    put :update, :id => workflows(:one).id, :workflow => { }
    assert_redirected_to workflow_path(assigns(:workflow))
=end
  end

  def test_should_destroy_workflow
    workflow = Workflow.first
    assert_difference('Workflow.count', -1) do
      delete :destroy, :id => workflow.id
    end

    assert_redirected_to issuetype_path(workflow.issuetype)
  end
end
