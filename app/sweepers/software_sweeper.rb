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
class SoftwareSweeper < ActionController::Caching::Sweeper
  # Used to clean up issue cache when logo updated
  observe Software

  # If sweeper detects that an Software was created or updated
  def after_save(record)
    expire_cache_for(record)
  end

  # If sweeper detects that an Software was deleted call this
  def after_destroy(record)
    expire_cache_for(record)
  end

  private
  def expire_cache_for(record)
    record.issues.each{|i| expire_fragments(i.fragments)}
  end
end
