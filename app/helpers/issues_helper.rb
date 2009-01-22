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
module IssuesHelper

  # Display a link to an issue
  # Options
  #  * :show_id display the id
  #  * :icon_severity display severity icon
  #  * :limit display only :limit caracters
  def link_to_issue(issue, options = {})
    return '-' unless issue
    text = options[:text]
    if text.nil?
      limit = options[:limit] || 50
      text = ''
      text << "##{issue.id} " if options.has_key? :show_id
      text << "#{StaticPicture::severity(issue)} " if options.has_key? :icon_severity #TODO
      text << truncate(issue.resume, limit)
    end
    link_to text, issue_path(issue)
  end

  def link_to_css_issue(issue, css_class)
    return '-' unless issue
    link_to "##{issue.id}", issue_path(issue), :class => css_class
  end

  def public_link_to_status_legend
    public_link_to(_("Status legend"), statuts_path, NEW_WINDOW)
  end

  # Display a link to the software or version or release
  # of an issue
  def link_to_issue_software(issue)
    return '-' unless issue
    path = ""
    path = software_path(issue.software) if issue.software
    path = version_path(issue.version) if issue.version
    path = release_path(issue.release) if issue.release
    link_to issue.full_software_name, path
  end

  def render_table(options)
    render :partial => "report_table", :locals => options
  end

  def render_detail(options)
    render :partial => "report_detail", :locals => options
  end

  # Display more nicely change to history table
  # Use it like :
  #  <%= display_history_changes(issue.engineer_id, old_engineer_id, User) %>
  def display_history_changes(field, old_field, model)
    if field
      if old_field and old_field == field
        '<center></center>'
      else
        model.find(field).name
      end
    else
      '<center>-</center>'
    end
  end

  # Used to call remote ajax action
  # Call it like :
  #  <% options = { :update => 'issue_tab',
  #     :url => { :action => nil, :id => @issue.id },
  #     :before => "Element.show('spinner')",
  #     :success => "Element.hide('spinner')" } %>
  #  <%= link_to_remote_tab('Description', 'ajax_description', options) %>
  def link_to_remote_tab(name, action_name, options)
    if (action_name != controller.action_name)
      link_to_remote name, options
    else
      link_to_remote name, options, :class => 'active'
    end
  end

  def link_to_new_issue(arg)
    options = arg ? new_issue_path(arg) : new_issue_path
    link_to image_create(_('New issue')), options
  end

  # Link to access a ticket
  def link_to_comment(ar)
      link_to StaticPicture::view, issue_path(ar)
  end

  def link_to_unlink_contribution( demand_id )
    link_to(_('Unlink the contribution'),
            unlink_contribution_issue_path(demand_id),
            :method => :post)
  end

  # TODO : Some patches can be refused by the community, and this
  # method does not treat this case.
  def link_to_issue_contribution(contribution)
    return '' unless contribution
    link = link_to _('patch'), contribution_path(contribution)
    (contribution.closed_on? ?
        _("The %s has been accepted by the community") % link :
        _("The %s has been submitted by the community") % link)
  end

  # TODO : Too much copy/paste
  # begining of factorisation in softwares_helper
  def remote_link_to_active_issue
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => issues_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=1; #{remote_function(ajax_call)}"
    link_to_function(_('Active issues'), js_call,
                     _('show issues waiting to be processed'))
  end

  def remote_link_to_dead_issue
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => issues_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=-1; #{remote_function(ajax_call)}"
    link_to_function(_('Finished issues'), js_call,
                     _('show issues that were processed'))
  end

  def remote_link_to_all_issue
    ajax_call =  PagesHelper::AJAX_OPTIONS.dup.update(:url => issues_path)
    js_call = "document.forms['filters'].elements['filters[active]'].value=0; #{remote_function(ajax_call)}"
    link_to_function(_('All issues'), js_call,
                     _('show all the issues'))
  end

  #usage : <tr <%= tr_attributes("../issues/comment/#{demand.id}")%> >
  def tr_attributes(href)
    "class=\"#{cycle('even', 'odd')}\" " <<
      "onclick=\"window.location.href='#{href}'\""
  end


  def display_commitment(req)
    return '-' unless req
    commitment = req.commitment
    if commitment
      "<p><b>%s: </b> %s<br /><b>%s: </b> %s</p>" %
        [ _('Workaround'), Time.in_words(commitment.workaround * 1.day, true),
          _('Correction'), Time.in_words(commitment.correction * 1.day, true) ]
    else
      '-'
    end
  end

  @@help_on_status = nil
  # Show the '?' icon with the link on status explanation on the wiki
  # TODO : this implementation can be improved a LOT
  def help_on_status
    @@help_on_status ||= %Q{<a href="#{App::Help::IssueStatusUrl}"} <<
       ' target="_blank" class="aligned_picture" style="vertical-align: top;">' <<
      image_tag("icons/question_mark.gif") <<
    '</a>'
  end

  @@help_on_severity = nil
  # Show the '?' icon with the link on severity explanation on the wiki
  # TODO : this implementation can be improved a LOT
  def help_on_severity
    @@help_on_severity ||= %Q{<a href="#{App::Help::IssueSeverityUrl}"} <<
       ' target="_blank" class="aligned_picture" style="vertical-align: top;">' <<
      image_tag("icons/question_mark.gif") <<
      '</a>'
  end

  # Shows a popup with the description of a status for the issue.
  # Ex: <%= link_to_box_on_status(@issue) %>
  def link_to_box_on_status(issue)
    return '' unless issue
    options = { :popup => ['help_statut', 'height=300,width=600'] }
    link_to(issue.statut.name, help_statut_path(issue.statut_id), options)
  end

  NEW_WINDOW = { :target => '_blank' }
  # Link to the inline help to post an issue
  def public_link_to_help_new_issue
    public_link_to(_("Submission of an issue"),
                   App::Help::NewIssueUrl, NEW_WINDOW)
  end

  # Link to the the inline help about life cycle of a demand
  def public_link_to_howto_issue
    public_link_to(_("The life cycle of an issue"),
                   App::Help::LifeCycleUrl, NEW_WINDOW)
  end

  # Link to the inline help about the differents states of a demand
  def public_link_to_help_issue_status
    public_link_to(_("Help on the status"),
                   App::Help::IssueStatusUrl, NEW_WINDOW)
  end

  def public_link_to_status_legend
    public_link_to(_("Status legend"), statuts_path, NEW_WINDOW)
  end

end
