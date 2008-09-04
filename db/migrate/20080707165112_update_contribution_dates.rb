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
class UpdateContributionDates < ActiveRecord::Migration
  # Needed for a cleaner & coherent display, since the form accept
  # only dates in current version
  def self.up
    change_column :contributions, :reverse_le, :date
    change_column :contributions, :cloture_le, :date
  end

  def self.down
    change_column :contributions, :reverse_le, :datetime
    change_column :contributions, :cloture_le, :datetime
  end
end
