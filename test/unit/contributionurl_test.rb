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

class ContributionurlTest < Test::Unit::TestCase
  fixtures :contributionurls, :contributions

  def test_to_strings
    check_strings Contributionurl
  end

  def test_attributes_presences
    u = Contributionurl.new
    assert !u.save
    assert u.errors.on(:valeur)
    assert u.errors.on(:contribution)

    contrib = contributions(:contribution_0001)
    u.update_attributes(:valeur => 'rubyonrails.org', :contribution => contrib)
    assert u.save
  end
end
