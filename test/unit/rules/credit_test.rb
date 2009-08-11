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
require File.dirname(__FILE__) + '/../../test_helper'

class Rules::CreditTest < ActiveSupport::TestCase
  fixtures :credits

  def test_to_strings
    check_strings Rules::Credit, :short_description
  end

  def test_rule
    credit = Rules::Credit.first
    assert credit.elapsed_on_create != 0

    contract = Contract.first
    assert !credit.elapsed_formatted(1, contract).blank?

    comment = Comment.first
    comment.elapsed = 4
    assert credit.compute_between(nil, comment, contract) != 0

    Rules::Credit.all.each do |c|
      assert !c.complete_description(1, contract).blank?
    end
  end

end
