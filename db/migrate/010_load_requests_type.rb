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
class LoadRequestsType < ActiveRecord::Migration
  class Typedemande < ActiveRecord::Base; end

  def self.up
    # Do not erase existing kind of requests
    return unless Typedemande.count == 0

    id = 1
    %w(Information Anomalie Évolution Monitorat
       Intervention Étude Livraison).each{ |tr|
      td = Typedemande.new(:nom => tr); td.id = id; td.save
      id = id + 1
    }
  end

  def self.down
    Typedemande.find(:all).each{ |td| td.destroy }
  end
end
