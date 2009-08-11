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
# Methods added to this helper will be available to all templates
# in the application. Don't ever add a method to this one without a really good
# reason. Anyway, this is a big helper, so find by keyword :
# - TEXT
# - FILES
# - LISTS ET TABLES
# - TIME

module ApplicationHelper
  include PagesHelper
  include FormsHelper
  include LinksHelper
  include PicturesHelper
  include TagsHelper

  ### TEXT #####################################################################
  # indent text and escape HTML caracters
  # Use on descriptions, comments, etc.
  def indent(text)
    (text.is_a? String) ? word_wrap(text).gsub("\n", '<br />') : text
  end

  # Small helper which prints '-' if something is nil or something.name
  def name(something)
    something ? something.name : '-'
  end

  def hide_unless(condition)
    (condition ? %Q{style="display: none;"} : '')
  end

  ### FILES #####################################################################
  def file_size(file)
    return '-' if file.blank? or not File.exists?(file)
    number_to_human_size(File.size(file))
  end

  ### LISTS ET TABLES ##########################################################
  # Display an Array of elements in a list manner
  # It takes a bloc in order to know what to display
  # Options :
  #  * :no_title : Set it to true for not displaying emphasis
  #  * :puce : allows to specify its own tag instead of '&lt;li&gt;'
  #  * :edit : name of the controllers needed to decorate list with
  #   an edit link and a delete link. Used widely in the show view of software.
  # If there is no block given, the field is displayed as is, with 'to_s' method.
  # Call it like :
  #   <%= show_list(@contribution.releases, 'contribution') {|e| e.name} %>
  def show_list(elements, name = '', options = {})
    elements.compact!
    size = elements.size
    result = ''
    return '' unless size > 0

    if !@session_user && options.has_key?(:public_summarized)
      return "<u><b>#{pluralize(size, name.to_s.capitalize)}" << _(' to date') << '</b></u><br />'
    end

    unless name.blank? or options.has_key? :no_title
      result << "<b>#{name.capitalize} : </b><br />"
    end

    # used mainly in welcome/about
    return show_simple_list(result, elements) unless block_given?

    # It can really be pretty ruby. We keep it under the hand
    # until yarv comes and so this code will be reasonabily fast
    # yield_or_default = proc {|e| (block_given? ? yield(e) : e) }
    result << '<ul>'
    edit = options[:edit]
    edit_call, delete_call = "edit_#{edit}_path","#{edit}_path" if edit
    elements.each { |e|
      elt = yield(e)
      unless elt.blank?
        result << '<li>'
        result << link_to_edit(send(edit_call, e)).to_s << ' ' if edit
        result << elt
        result << ' ' << link_to_delete(send(delete_call, e)).to_s if edit
        result << '</li>'
      end
    }
    result << '</ul>'
    result
  end

  # Private call, used by show_list on certain simple case
  def show_simple_list(result, elements)
    result << '<ul>'
    elements.each { |e| result << "<li>#{e}</li>" unless e.blank? }
    result << '</ul>'
  end

  # Call it like :
  # <% titles = ['File', 'Size', 'Author', 'Updated on'] %>
  # <%= show_table(@attachments, Attachment, titles) { |e| "<td>#{e.name}</td>" } %>
  # Do NOT forget to use <td></td>
  # Options
  #   :total > deactivate total count
  #   :content_columns > use Rails AR fonctionnality
  #   :add_lines > add the string at the end of the table
  #   :width > html options for global table width
  def show_table(elements, ar, titles, options = {})
    return '<p>' << _('No %s at the moment') % _(ar.table_name.singularize) + '</p>' unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : '' )
    result = "<table #{width} class=\"full\">"
    content_columns = options.has_key?(:content_columns)

    if titles
      result << '<thead><tr>'
      if (content_columns)
        ar.content_columns.each{|c| result <<  "<th>#{c.human_name}</th>"}
      end
      #On doit mettre nowrap="nowrap" pour que ça soit valide XHTML
      titles.each {|t| result << "<th nowrap=\"nowrap\">#{t}</th>" }
      result << '</tr></thead>'
    end

    elements.each_index { |i|
      result << "<tr class=\"#{cycle('even', 'odd')}\">"
      if (content_columns)
        ar.content_columns.each {|column|
          result << "<td>#{elements[i].send(column.name)}</td>"
        }
      end
      result << yield(elements[i])
      result << '</tr>'
    }

    if (options.has_key? :add_lines)
      options[:add_lines].each {|line|
        result << "<tr>"
        line.each {|cell|
          result << "<td>#{cell}</td>"
        }
        result << "</tr>"
      }
    end
    result << '</table>'
  end



  ### MENU #####################################################################

  # Display a simple menu (without submenu) from an array
  # a field may be add in the array, to select a ticket
  # Options
  #  * :form include all in a form_tag
  #  * :add_class specifie a class to overide .simple_menu style
  def build_simple_menu(menu, options={})
    return unless menu.is_a? Array
    menu.compact!
    out = ''
    out << form_tag(issues_path || '', :method => :get) if options.has_key? :form
    out << ' <ul>'
    menu.each { |e| out << "<li>#{e}</li>" }
    out << ' </ul>'
    out << '</form>' if options[:form]
  end


  ### INFORMATIONS #########################################################

  def show_notice
    @@notice ||= %Q{<div id="information_notice" class="information notice">
       <div class="close_information">#{delete_button('information_notice')}</div>
       <script type="text/javascript">
          setTimeout(function() { new Effect.Fade("information_notice",{duration:1});
                                }, 4000);
       </script>}
    @@notice.dup << "<p>#{flash[:notice]}</p></div>"
  end

  def show_warn
    @@warn ||= %Q{<div id="information_error" class="information error">
       <div class="close_information">#{delete_button('information_error')}</div>}
    @@warn.dup << "<h2>#{_('An error has occured')}</h2>" <<
      "<ul><li>#{flash[:warn]}</li></ul></div>"
  end

end
