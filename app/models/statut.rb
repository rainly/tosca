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
class Statut < ActiveRecord::Base
  has_many :issues

  #######################################
  I18n.t(:submitted) #1  	Enregistrée     #
  I18n.t(:accepted)  #2	Accepté         #
  I18n.t('Suspended') #3	Suspendue       #
  I18n.t('Analysed')  #4	Analysée        #
  I18n.t('Bypassed')  #5 	Contournée      #
  I18n.t('Fixed')     #6	Corrigée        #
  I18n.t('Closed')    #7	Clôturée        #
  I18n.t('Cancelled') #8    Annulée         #
  #######################################

  # used in lib/comex_reporting and models/issue.rb
  # Please be EXTREMELY cautious if you touch them.
  OPENED = [ 1, 2, 3, 4, 5 ] # We need to work on it
  CLOSED = [ 6, 7, 8 ] # The time count is now less/not important

  NEED_COMMENT = [ 3, 4, 8 ] #These status need a comment if you use them, Suspended, Analysed, Cancelled

  Running = [ 1, 2, 4, 5 ] # Chrono is up

  # We do not want in any case a modification on those ids
  [ OPENED, CLOSED ].each do |xs|
    xs.each{|x| x.freeze}.freeze
  end

  # Used by elapsed cache, see Elapsed model for more info.
  Active, Bypassed, Fixed= 2, 5, 6

  # It's one of the rare "heavily used & fixed" AR model,
  # So we can include it in the translation mechanism
  def name
    I18n.t(read_attribute(:name))
  end

end
