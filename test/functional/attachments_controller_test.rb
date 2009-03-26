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

class AttachmentsControllerTest < ActionController::TestCase

  def setup
    login 'admin', 'admin'
  end

  def test_create
    num_attachments = Attachment.count

    post :create, :attachment => {
      :file => uploaded_png("#{File.expand_path(RAILS_ROOT)}/test/fixtures/upload_document.png"),
      :comment => Comment.first(:order => :id)
    }

    assert_response :redirect
    assert_redirected_to attachment_path(assigns(:attachment))

    assert_equal num_attachments + 1, Attachment.count
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    attachment = Attachment.find(1)
    assert_not_nil attachment

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert_raise(ActiveRecord::RecordNotFound) {
      Attachment.find(1)
    }

    attachment = fixture_file_upload('../../app/models/attachment.rb')
    options = { :file => attachment, :comment => comments(:comment_00001) }
    attachment = Attachment.new(options)
    attachment.id = 1
    assert attachment.save
    assert_not_nil Attachment.find(1)
  end

end
