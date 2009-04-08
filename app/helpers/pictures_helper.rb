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

module PicturesHelper

  #Create icon with a nice tooltip
  def image_create(message)
    desc = _("Add %s") % message
    image_tag("icons/add.png", image_options(desc, '16x16'))
  end

  def image_next_page
    image_tag("icons/resultset_next.png", image_options(_('Previous Page'), '16x16'))
  end

  def image_prev_page
    image_tag("icons/resultset_previous.png", image_options(_('Next Page'), '16x16'))
  end

  #Disconnect icon with the tooltip
  def image_disconnect
    image_tag('icons/disconnect.gif', image_options(_('Logout'), '16x16'))
  end

  #Connect icon with the tooltip
  def image_connect
    image_tag('icons/connect.png', image_options(_('Log in'), '16x16'))
  end

  def image_star(desc)
    image_tag('icons/star.png', image_options('', '16x16'))
  end

  def image_expand_all
    image_tag('icons/expand_all.png', image_options(_('Expand all'), '16x16'))
  end

  def image_collapse_all
    image_tag('icons/collapse_all.png', image_options(_('Collapse all'), '16x16'))
  end

  def image_view
    image_tag('icons/zoom.png', image_options(_('View'), '16x16'))
  end

  def image_edit
    image_tag('icons/pencil.png', image_options(_('Update'), '16x16'))
  end

  # You should prefer to use
  # image_create(message) : with message being a good tooltip for the link
  def image_add
    image_tag('icons/add.png', image_options(_('Add'), '16x16'))
  end

  def image_delete
    image_tag('icons/cancel.png', image_options(_('Delete'), '16x16'))
  end

  def image_hide_notice
    image_tag('icons/cancel.png', image_options(_('Hide'), '16x16'))
  end

  def image_help
    image_tag('icons/help.png', image_options(_('Help'), '16x16'))
  end

  # Navigation
  def image_back
    image_tag("icons/arrow_undo.png", image_options(_('Back'), '16x16'))
  end

  def image_first_page
    image_tag("icons/resultset_first.png",
              image_options(_("First page"), '16x16'))
  end

  def image_previous_page
    image_tag("icons/resultset_previous.png",
               image_options(_("Previous page"), '16x16'))
  end

  def image_next_page
    image_tag("icons/resultset_next.png",
              image_options(_("Next page"), '16x16'))
  end

  def image_last_page
    image_tag("icons/resultset_last.png", image_options(_("Last page"), '16x16'))
  end

  def image_folder
    image_tag('icons/folder.png', image_options(_("File"), '16x16'))
  end

  def image_patch
    image_tag('icons/page_code.png', image_options(_("Contribution"), '16x16'))
  end

  # Logos
  @@logo_service = nil
  def image_logo_service
    @@logo_service ||= image_tag("service_image.gif", image_options(App::ContactPhone))
  end

  @@logo_service_small = nil
  def image_logo_service_small
    @@logo_service_small ||= image_tag("service_image_small.gif", image_options(App::ContactPhone))
  end

  def image_tosca
    image_tag('logo_tosca.gif', image_options(_('Home page')))
  end

  @@ruby = nil
  def image_ruby
    @@ruby ||= image_tag('icons/ruby.gif', image_options("Tosca on Rails", '15x15'))
  end

  @@linagora = nil
  def image_linagora
    @@linagora ||= image_tag('logo_linagora.gif', image_options('Tosca on Rails', '176x44'))
  end

  @@favimage_png = nil
  def image_favimage_png
    @@favimage_png ||= image_path("icons/favicon.png")
  end

  @@favimage_ico = nil
  def image_favimage_ico
    @@favimage_ico ||= image_path("icons/favicon.ico")
  end

  def image_print
    image_tag('icons/printer.png', image_options(_('Print'), '16x16'))
  end

  # type mime icons
  @@mime_txt = nil
  def image_mime_txt
    @@mime_txt ||= image_tag('icons/mime-type/txt.png')
  end

  @@mime_pdf = nil
  def image_mime_pdf
    @@mime_pdf ||= image_tag('icons/mime-type/pdf.png')
  end

  @@mime_ods = nil
  def image_mime_ods
    @@mime_ods ||= image_tag('icons/mime-type/ods.png')
  end

  @@mime_csv = nil
  def image_mime_csv
    @@mime_csv ||= image_tag('icons/mime-type/csv.png')
  end

  # Other
  @@spinner = nil
  def image_spinner
    @@spinner ||= image_tag('spinner.gif', :id => 'spinner',
                            :style=> 'display: none;')
  end

  def image_icon_tag
    image_tag('icons/tag_red.gif', image_options(_('Manage tags'), '16x16'))
  end

  def image_icon_css
    image_tag('icons/css.png', image_options('', '16x16'))
  end

  def image_expand
    image_tag('icons/navigation_expand.gif', image_options(_('expand')))
  end

  def image_hide
    image_tag('icons/navigation_hide.gif', image_options(_('hide')))
  end

  def image_checkbox
    image_tag 'icons/checkbox.gif', image_options(_('Checkbox'), '13x13')
  end

  def image_sla_ok
    image_tag 'icons/accept.png', image_options(_('Time achieved'), '16x16')
  end

  def image_sla_running
    image_tag 'icons/time.png', image_options(_('Time is running'), '16x16')
  end

  def image_sla_exceeded
    image_tag 'icons/exclamation.png', image_options(_('Time exceeded'), '16x16')
  end

  def image_comments
    image_tag('icons/comments.png', image_options(_('Comments'), '16x16'))
  end

  def image_documents
    image_tag('icons/page_copy.png', image_options(_('Attachments'), '16x16'))
  end

  def image_phonecalls
    image_tag('icons/phonecalls.png', image_options(_('Phonecalls'), '16x16'))
  end

  def image_description
    image_tag('icons/book_open.png', image_options(_('Description'), '16x16'))
  end

  def image_history
    image_tag('icons/film.png', image_options(_('History'), '16x16'))
  end

  def image_subscribe
    image_tag('icons/report_add.png', image_options(_('Subscribe'), '16x16'))
  end

  def image_unsubscribe
    image_tag('icons/report_delete.png', image_options(_('Unsubscribe'), '16x16'))
  end

  def image_subscription
    image_tag('icons/feed.png', image_options(_('Subscribed'), '16x16'))
  end

  @@new = nil
  def image_new
    image_tag('icons/new.png', image_options(_('New'), '16x16'))
  end

  def image_stop
    image_tag('icons/stop.png', image_options(_('Stop'), '16x16'))
  end

  ##############################################
  # Severity
  # Display an icon matching severity
  # They are stored in an array in order to cover all of 'em
  @@images_severity = nil
  def image_severity(d)
    @@images_severity ||= Array.new(Severity.count)
    result = @@images_severity[d.severity_id]
    if result.nil?
      desc = (d.respond_to?(:severities_name) ? d.severities_name : d.severity.name)
      file_name = "severity_#{d.severity_id}.gif"
      @@images_severity[d.severity_id] = image_tag(file_name, :title => desc,
        :alt => desc, :class => 'aligned_picture')
      result = @@images_severity[d.severity_id]
    end
    result
  end




  @@date_opt = { :size => '16x16',
    :onmouseover => "this.className='calendar_over';", :class => 'calendar_out',
    :onmouseout => "this.className='calendar_out';", :style => 'cursor: pointer;'
  }

  def script_date_from
    options = { :alt => _("Choose a date"),
      :title => _("Select a date"), :id => 'date_from' }
    image_tag('icons/cal.gif', @@date_opt.dup.update(options))
  end

  def script_date_to
    options = { :alt => _("Choose a date"),
      :title => _("Select a date"), :id => 'date_from' }
    image_tag('icons/cal.gif', @@date_opt.dup.update(options))
  end

  # used to generate js for calendar. It uses an array of 2 arguments. See
  # link:"http://www.dynarch.com/projects/calendar/"
  #
  # first args : id of input field
  #
  # second args : id of image calendar trigger
  #
  # call it : <%= script_date('date_before', 'date_to') %>
  def script_date(*args)
    '<script type="text/javascript">
       Calendar.setup({
        firstDay       :    0,            // first day of the week
        inputField     :    "%s", // id of the input field
        button         :    "%s",  // trigger for the calendar (button ID)
        align          :    "Tl",         // alignment : Top left
        singleClick    :    true,
             ifFormat       : "%%Y-%%m-%%d"  // our date only format
         });
   </script>' % args
  end




  private

  # por éviter la réaffection de desc à chaque coup
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc }
    options[:size] = size if size
    options
  end

  # Beware that the inactive thumb is only available for thumb size
  # Call like this :
  #  <%= logo_client(@client) %>
  #  <%= logo_client(@client, :small) %>
  def logo_client(client, size = :thumb)
    return '' if client.nil? or size.nil?
    return client.name if client.picture.blank?
    if size == :thumb
      size = (client.inactive? ? :inactive_thumb : :thumb)
    end
    image_tag(url_for_image_column(client.picture, 'image', size) || client.name,
              image_options(client.name_clean))
  end

  # Display the software's logo, if possible
  # Possible options are those specified in image model.
  # Currently :small, :thumb, :medium, :inactive_thumb
  def software_logo(software, options = {})
    return '' if software.nil? or software.picture.blank?
    size = options[:size] || :small
    path = url_for_image_column(software.picture, 'image', size)
    return '' if path.blank?
    image_tag(path, :class => "aligned_picture",
              :alt => software.name, :title => software.name)
  end

  # See usage in reporting_helper#progress_bar
  # It show a percentage of progression.
  def image_percent(percent, color, desc)
    style = "background-position: #{percent}px; background-color: #{color};"
    options = { :alt => desc, :title => desc, :style => style,
      :class => 'percentImage aligned_picture' }
    image_tag('percentimage.png', options)
  end

  # call it like :
  # <%= link_to_new_version(@software) %>
  def link_to_new_client_logo
    link_to(image_create(_('a logo')), new_picture_path, :target => '_blank')
  end

end
