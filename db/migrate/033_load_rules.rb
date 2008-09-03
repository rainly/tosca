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
class LoadRules < ActiveRecord::Migration
  class Ossa < ActiveRecord::Base; end
  class TimeTicket < ActiveRecord::Base; end

  def self.up
    Ossa.create(:name => 'Ossa', :max => -1)
    TimeTicket.create(:name => 'Support Gold', :max => 160)
    TimeTicket.create(:name => 'Support Silver', :max => 80)
  end

  def self.down
    Ossa.find(:all).each{ |o| o.destroy }
    TimeTicket.find(:all).each{ |tt| tt.destroy }
  end
end
