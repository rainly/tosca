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

class IssueTest < ActiveSupport::TestCase

  def test_to_strings
    check_strings Issue, :resume, :description
  end

  def test_presence_of_attributes
    recipient = users(:user_customer)
    issue = Issue.new({:description => 'description', :resume => 'resume',
        :recipient => recipient, :submitter => recipient,
        :statut => statuts(:statut_00001), :severity => severities(:severity_00001),
        :contract_id => recipient.contracts.first.id })
    # must have a recipient
    assert issue.save

    # comment table must have things now ...
    c = Comment.find :first, :conditions => { :issue_id => issue.id }
    assert_equal c.issue_id, issue.id
    assert_equal c.severity, issue.severity
    assert_equal c.statut, issue.statut
    assert_equal c.engineer, issue.engineer
  end

  def test_scope
    assert Issue.respond_to?(:set_scope)
    User.all.each do |u|
      Issue.set_scope(u)
      Issue.all.each do |i|
        assert u.contract_ids.include?(i.contract_id) unless u.admin?
      end
      Issue.remove_scope
    end
  end

  def test_helpers
    Issue.all.each{|i| assert !i.pretty_id.blank? }
    Issue.new.set_defaults(User.first, :software_id => 1)
  end

  def test_arrays
    check_arrays Issue, :remanent_fields
  end

  def test_fragments
    assert !Issue.first(:order => :id).fragments.empty?
  end

  def test_finder
    issue = issues(:issue_00010)
    comment = issue.find_status_comment_before(issue.last_status_comment)
    assert_not_nil comment
  end

  def test_helpers_function
    Issue.all.each { |r|
      r.time_running?
      r.critical?
      assert_not_nil r.client
      assert_not_nil r.commitment
      assert_instance_of Fixnum, r.interval
      # they can be nil, but we need to check'em too
      r.elapsed_formatted
      r.full_software_name
    }
  end

  def test_pending_helpers
    Issue.find_pending_user(User.recipients.first)
    Issue.find_pending_user(User.engineers.first)
    Issue.find_pending_contracts([Contract.first.id])
  end


  def test_reset_elapsed
    Issue.first(:order => :id).reset_elapsed
  end

  def test_set_defaults
    issue = Issue.first(:order => :id)
    issue.statut_id = nil
    issue.set_defaults(issue.recipient, {})
    issue.set_defaults(issue.engineer, {})
  end

end
