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

class ReportingControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    login 'admin', 'admin'
  end

  def test_reporting
    get :configuration
    assert_response :success
    assert_template 'configuration'
    assert_not_nil assigns(:contracts)

    form = select_form 'main_form'
    form.reporting.contract_ids = [ '1', '2' ]
    form.submit

    assert_response :success
    assert_template 'general'
    assert_not_nil assigns(:contracts)
  end

  def test_monthly
    get :monthly

    xhr :get, :monthly, :filters => { :contract_id => Contract.first.id.to_s }
    assert_response :success
    xhr :get, :monthly, :filters => { :team_id => Team.first.id.to_s }
    assert_response :success
    xhr :get, :monthly, :date => { :month => '1', :year => '2009' }
    assert_response :success
  end

  def test_weekly
    get :weekly

    xhr :get, :weekly, :filters => { :contract_id => Contract.first.id.to_s }
    assert_response :success
    xhr :get, :weekly, :filters => { :team_id => Team.first.id.to_s }
    assert_response :success
    xhr :get, :weekly, :report => { :start_date => '2008-12-29' }
    assert_response :success
  end

end
