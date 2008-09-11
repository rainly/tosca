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
module ContributionsHelper

  # this dump the pretty table of all contributions of the
  # software in parameters
  def public_table_of_contributions(contribs)
    return '' unless contribs.size > 0
    columns = [ _('Date'), _('Version'), _('Summary') ]
    out = '<div class="bloc_scroll"><table class="show"><tr>'
    columns.each { |c| out << "<th>#{c}</th>" }
    out << '</tr>'
    contribs.each{|c|
      out << "<tr class=\"#{cycle('even', 'odd')}\">"
      out << "<td>#{c.contributed_on_formatted}</td>"
      out << "<td>#{c.affected_version}</td>"
      out << "<td>#{public_link_to_contribution(c)}</td>"
      out << '</tr>'
    }
    out << '</table></div>'
  end

  # call it like : link_to_contribution_logiciel
  def public_link_to_contribution_logiciel(logiciel, params = {})
    return '-' unless logiciel
    path = list_contribution_path(logiciel.id)
    client_id = params[:client_id]
    count = 0
    unless client_id.blank?
      path << "?client_id=#{params[:client_id]}"
      options = { :conditions => { :logiciel_id => logiciel.id } }
      unless client_id == '1' # Main client, with the old portal
        options[:include] = { :request => :contract }
        options[:conditions].merge!({'contracts.client_id' => params[:client_id]})
      end
      # Dirty hack in order to show main client' contributions
      # TODO : remove it in september.
      condition = (client_id == '1' ? "contributions.id_mantis IS NOT NULL" : '')
      scope = { :find => { :conditions => condition } }
      Contribution.send(:with_scope, scope) do
        count = Contribution.count(:all,options)
      end
    else
      count = logiciel.contributions.size
    end
    public_link_to "#{logiciel.name} (#{count})", path
  end

  # call it like :
  # <%= link_to_new_contribution %>
  def link_to_new_contribution(text = nil, options = { })
    options = new_contribution_path(options)
    if text
      link_to(text, options)
    else
      link_to image_create(_('a contribution')), options
    end
  end

  # call it like :
  # <%= link_to_contribution @contribution %>
  def link_to_contribution(c)
    return '-' unless c
    link_to c.name, contribution_url(c)
  end

  def public_link_to_contribution(c)
    return '-' unless c
    public_link_to(c.name, contribution_path(c))
  end

  # une contribution peut être liée à une request externe
  # le "any" indique que la request peut etre sur n'importe quel tracker
  def link_to_any_request(contribution)
    return ' - ' if not contribution or not contribution.id_mantis
    out = ''
    if contribution.id_mantis
      out << "<a href=\"http://www.08000linux.com/clients/minefi_SLL/mantis/view.php?id=#{contribution.id_mantis}\">
       Mantis ##{contribution.id_mantis}</a>"
    end
    out
  end

end
