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

require 'static'

# This helpers is here to put in cache most of images
# urls generation. The images do not moves after the
# web server is launched, so there are computed only the
# first time one needs it and saved in class variables.
#
# You need to restart server in order to reinitialize them
# but you don't need to recompute them each time you want
# to display a picture.
#
# All images follow this scheme :
#   @@view = nil
#   def self.view
#     @@view ||= tag('icons/b_view.png', options('Consulter', '15x15'))
#   end
class StaticPicture < Static::ActionView

  #########################################################

  # To have globals options
  def self.options(desc = '', size = nil)
    options = { :alt => desc, :title => desc, :class => 'aligned_picture' }
    options[:size] = size if size
    options
  end

  @@view = nil
  def self.view
    desc = I18n.t("View")
    @@view ||= image_tag('icons/zoom.png', options(desc, '16x16'))
  end

  @@edit = nil
  def self.edit
    desc = I18n.t("Update")
    @@edit ||= image_tag('icons/pencil.png', options(desc, '16x16'))
  end

  # You should prefer to use
  # image_create(message) : with message being a good tooltip for the link
  @@add = nil
  def self.add
    desc = I18n.t('Add')
    @@add ||= image_tag('icons/add.png', options(desc, '16x16'))
  end

  @@delete = nil
  def self.delete
    desc = I18n.t("Delete")
    @@delete ||= image_tag('icons/cancel.png', options(desc, '16x16'))
  end

  @@hide_notice = nil
  def self.hide_notice
    desc = I18n.t("Hide")
    @@hide_notice ||= image_tag('icons/cancel.png', options(desc, '16x16'))
  end

  @@help = nil
  def self.help
    desc = I18n.t("Help")
    @@help ||= image_tag('icons/help.png', options(desc, '16x16'))
  end

  # Navigation
  @@back = nil
  def self.back
    desc = I18n.t("Back")
    @@back ||= image_tag("icons/arrow_undo.png", options(desc, '16x16'))
  end

  @@first_page = nil
  def self.first_page
    desc = I18n.t("First page")
    @@first_page ||= image_tag("icons/resultset_first.png", options(desc, '16x16'))
  end

  @@previous_page = nil
  def self.previous_page
    desc = I18n.t("Previous page")
    @@previous_page ||= image_tag("icons/resultset_previous.png", options(desc, '16x16'))
  end

  @@next_page = nil
  def self.next_page
    desc = I18n.t("Next page")
    @@next_page ||= image_tag("icons/resultset_next.png", options(desc, '16x16'))
  end

  @@last_page = nil
  def self.last_page
    desc = I18n.t("Last page")
    @@last_page ||= image_tag("icons/resultset_last.png", options(desc, '16x16'))
  end

  @@folder = nil
  def self.folder
    desc = I18n.t("File")
    @@folder ||= image_tag('icons/folder.png', options(desc, '16x16'))
  end

  @@patch = nil
  def self.patch
    desc = I18n.t("Contribution")
    @@patch ||= image_tag('icons/page_code.png', options(desc, '16x16'))
  end

  # Security
  @@public = nil
  def self.public
    desc = I18n.t("Make public")
    @@public ||= image_tag('icons/lock_open.png', options(desc, '16x16'))
  end

  @@private = nil
  def self.private
    desc = I18n.t("Make private")
    @@private ||= image_tag('icons/lock.png', options(desc, '16x16'))
  end

  # Logos
  @@logo_service = nil
  def self.logo_service
    @@logo_service ||= image_tag("service_image.gif", options(App::ContactPhone))
  end

  @@logo_service_small = nil
  def self.logo_service_small
    @@logo_service_small ||= image_tag("service_image_small.gif", options(App::ContactPhone))
  end

  @@tosca = nil
  def self.tosca
    desc = I18n.t(:Homepage)
    @@tosca ||= image_tag('logo_tosca.gif', options(desc))
  end

  @@ruby = nil
  def self.ruby
    desc = I18n.t(:tosca_on_rails)
    @@ruby ||= image_tag('icons/ruby.gif', options(desc, '15x15'))
  end

  @@favimage_png = nil
  def self.favimage_png
    @@favimage_png ||= image_path("icons/favicon.png")
  end

  @@favimage_ico = nil
  def self.favimage_ico
    @@favimage_ico ||= image_path("icons/favicon.ico")
  end

  @@print = nil
  def self.print
    desc = I18n.t("Print")
    @@print ||= image_tag('icons/printer.png', options(desc, '16x16'))
  end

  # type mime icons
  @@mime_txt = nil
  def self.mime_txt
    @@mime_txt ||= image_tag('icons/mime-type/txt.png')
  end

  @@mime_pdf = nil
  def self.mime_pdf
    @@mime_pdf ||= image_tag('icons/mime-type/pdf.png')
  end

  @@mime_ods = nil
  def self.mime_ods
    @@mime_ods ||= image_tag('icons/mime-type/ods.png')
  end

  @@mime_csv = nil
  def self.mime_csv
    @@mime_csv ||= image_tag('icons/mime-type/csv.png')
  end

  # Other
  @@spinner = nil
  def self.spinner
    @@spinner ||= image_tag('spinner.gif', :id => 'spinner',
                            :style=> 'display: none;')
  end

  @@icon_tag = nil
  def self.icon_tag
    desc = I18n.t("Manage tags")
    @@icon_tag ||= image_tag('icons/tag_red.gif', options(desc, '16x16'))
  end

  @@icon_css = nil
  def self.icon_css
    @@icon_tag ||= image_tag('icons/css.png', options('', '16x16'))
  end

  @@expand = nil
  def self.expand
    @@expand ||= image_tag('icons/navigation_expand.gif', options('expand'))
  end

  @@hide = nil
  def self.hide
    @@hide ||= image_tag('icons/navigation_hide.gif', options('hide'))
  end

  @@checkbox = nil
  def self.checkbox
    @@checkbox ||= image_tag 'icons/checkbox.gif', options('Checkbox', '13x13')
  end

  @@sla_ok = nil
  def self.sla_ok
    @@sla_ok ||= image_tag 'icons/accept.png', options('Time achieved', '16x16')
  end

  @@sla_running = nil
  def self.sla_running
    @@sla_running ||= image_tag 'icons/time.png', options('Time is running', '16x16')
  end

  @@sla_exceeded = nil
  def self.sla_exceeded
    @@sla_exceeded ||= image_tag 'icons/exclamation.png', options('Time exceeded', '16x16')
  end

  @@comments = nil
  def self.comments
    @@comments ||= image_tag('icons/comments.png', options('Comments', '16x16'))
  end

  @@documents = nil
  def self.documents
    @@documents ||= image_tag('icons/page_copy.png', options('Attachments', '16x16'))
  end

  @@phonecalls = nil
  def self.phonecalls
    @@phonecalls ||= image_tag('icons/phonecalls.png', options('Phonecalls', '16x16'))
  end

  @@description = nil
  def self.description
    @@description ||= image_tag('icons/book_open.png', options('Description', '16x16'))
  end

  @@history = nil
  def self.history
    @@history ||= image_tag('icons/film.png', options('History', '16x16'))
  end

  @@subscribe = nil
  def self.subscribe
    @@subscribe ||= image_tag('icons/report_add.png', options('Subscribe', '16x16'))
  end

  @@unsubscribe = nil
  def self.unsubscribe
    @@unsubscribe ||= image_tag('icons/report_delete.png', options('Unsubscribe', '16x16'))
  end

  @@subscription = nil
  def self.subscription
    @@subscription ||= image_tag('icons/feed.png', options('Subscribed', '16x16'))
  end

  @@new = nil
  def self.new
    @@new ||= image_tag('icons/new.png', options('New', '16x16'))
  end

  @@stop = nil
  def self.stop
    @@stop ||= image_tag('icons/stop.png', options('Stop', '16x16'))
  end

  ##############################################
  # Severity
  # Display an icon matching severity
  # They are stored in an array in order to cover all of 'em
  @@images_severity = Array.new(Severity.count)
  def self.severity(d)
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


end
