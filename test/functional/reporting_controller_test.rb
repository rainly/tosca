#
# Copyright (c) 2006-2008 Linagora
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

  def setup
    login 'admin', 'admin'
  end

=begin
  # deactivated for now

  def test_comex_cns
    get :comex_resultat, {
      :results => { :week_num => 33 },
      :clients => ['all'],
      :cns => 'Voir l\'avancement du CNS'
    }
    assert_response :success
    assert_template 'comex_resultat'
  end
=end

end
