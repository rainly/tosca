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
class MoveLogicielImageForeignKey < ActiveRecord::Migration
  def self.up
    add_column :images, :logiciel_id, :integer
    # Needed 4 sqlite
    remove_index :logiciels, :image_id
    remove_column :logiciels, :image_id
  end

  def self.down
    remove_column :images, :logiciel_id
    add_column :logiciels, :image_id, :integer
  end
end
