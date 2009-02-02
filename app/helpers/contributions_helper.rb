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
module ContributionsHelper

  # this dump the pretty table of all contributions of the
  # software in parameters
  def public_table_of_contributions(contribs)
    return '' unless contribs.size > 0
    columns = [ I18n.t('Date'), I18n.t('Version'), I18n.t('Summary') ]
    out = '<div class="bloc_scroll"><table class="full"><tr>'
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

  # call it like : link_to_contribution_software
  def public_link_to_contribution_software(software, params = {})
    return '-' unless software
    path = list_contribution_path(software.id)
    client_id = params[:client_id]
    count = 0
    unless client_id.blank?
      path << "?client_id=#{params[:client_id]}"
      options = { :conditions => { :software_id => software.id } }
      unless client_id == '1' # Main client, with the old portal
        options[:include] = { :issue => :contract }
        options[:conditions].merge!({'contracts.client_id' => params[:client_id]})
      end
      count = Contribution.count(:all,options)
    else
      count = software.contributions.size
    end
    public_link_to "#{software.name} (#{count})", path
  end

  # call it like :
  # <%= link_to_new_contribution %>
  def link_to_new_contribution(text = nil, options = { })
    options = new_contribution_path(options)
    if text
      link_to(text, options)
    else
      link_to image_create(I18n.t('a contribution')), options
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
end
