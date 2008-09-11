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
class UserSweeper < ActionController::Caching::Sweeper
  # Currently used to maintain cache correctly for request & comments
  observe User

  # If sweeper detects that a Request was created or updated
  def after_save(record)
    expire_cache_for(record)
  end

  # If sweeper detects that a Request was deleted call this
  def after_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    # Refresh User Info on each cache displaying it
    Request.actives(record.contract_ids).each { |d|
      expire_fragments d.fragments
    }
  end
end
