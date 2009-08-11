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

class ElapsedTest < ActiveSupport::TestCase

  def test_to_strings
    check_strings Elapsed
  end

  def test_elapsed_life_cycle
    Issue.first.elapsed.destroy
    e = Elapsed.new(Issue.first)

    comment = Comment.first(:conditions => {:statut_id => 2})
    comment.elapsed = 1
    e.add comment
    assert( e.taken_into_account != 0 )
    assert( e.taken_into_account_progress != 0 )

    comment.statut_id = 5
    e.add comment
    assert( e.workaround != 0 )
    assert( e.workaround_progress(8/24.0) != 0 )
    e.remove comment

    comment.statut_id = 7
    e.add comment
    assert( e.correction != 0 )
    assert( e.correction_progress(8/24.0) != 0 )


  end

end
