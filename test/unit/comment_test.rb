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

class CommentTest < ActiveSupport::TestCase
  include ActionController::TestProcess

  def test_to_strings
    check_strings Comment
  end

  # We ensure to call all the methods
  def test_helper_methods
    c = Comment.first(:order => :id)
    c.state
    c.mail_id
    c.first_comment?
    # TODO : call it with multiple files
    assert c.add_attachments({})
    image_file = fixture_file_upload('/files/logo_linagora.gif', 'image/gif')
    assert c.add_attachments(:attachments => {'0' => {:file => image_file}})
    c.fragments
  end

  def test_create_comment
    c = Comment.new(:text => 'this is a comment',
      :issue => Issue.first(:order => :id),
      :user => User.first(:order => :id))
    assert c.save!
    # test automatic status & assignment text
    c = Comment.new(:text => '',
                    :statut_id => 7,
                    :issue => Issue.first(:order => :id),
                    :user => User.first(:order => :id),
                    :engineer => User.engineers.first)
    assert c.save!
    # test automatic assignmenttatus text
    c = Comment.new(:issue => Issue.first(:order => :id),
                    :user => User.first(:order => :id))
    assert c.save!
    c = Comment.new(:text => 'this is a comment',
      :issue => Issue.first(:order => :id),
      :user => User.first(:order => :id),
      :private => false, :statut_id => 1)
    assert c.save!
    # cannot change privately the status
    c = Comment.new(:text => 'this is a comment',
      :issue => Issue.first(:order => :id),
      :user => User.first(:order => :id),
      :private => true, :statut_id => 1)
    assert !c.save
    # cannot declare a comment without a issue
    c = Comment.new(:text => 'this is a comment',
      :user => User.first(:order => :id),
      :private => true, :statut_id => 1)
    assert !c.save
  end

  # last call to destroy will cover the special case of update_status
  def test_update_status
    d = Issue.first(:order => :id)
    d.comments.each { d.destroy }
  end

  def test_automatic_subscription
    issue = Issue.first(:order => :id)
    user = User.first(:order => :id)
    c = Comment.new(:text => 'this is a comment',
      :issue => issue,
      :user => user)
    assert c.save!
    assert issue.subscribed?(user)
  end

  def test_scope
    private_comment = { :conditions => { :private => true }}
    assert Comment.first(private_comment)
    Comment.set_private_scope
    assert !Comment.first(private_comment)
    Comment.remove_scope
  end
end
