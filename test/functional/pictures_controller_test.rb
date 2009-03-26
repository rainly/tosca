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

class PicturesControllerTest < ActionController::TestCase
  fixtures :pictures

  def setup
    login 'admin', 'admin'
  end

  def test_destroy
    image = Picture.first(:order => :id)
    assert_not_nil image

    assert_difference('Picture.count', -1) do
      post :destroy, :id => 1
    end
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Picture.find(image.id)
    }
    image.save
  end
end
