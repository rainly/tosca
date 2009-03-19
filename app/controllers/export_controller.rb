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

=begin
  send formatted output directly to the HTTP response
  source : http://wiki.rubyonrails.org/rails/pages/HowtoExportDataAsCSV
  All this controller see the same scheme.
  For a model exported "me", you will have :
  def me :
    which explains will format will be supported and how
  def compute_me :
    which explains will datas will be exported in all of those formats
 All those export finishes with the call to #generate_report,
 which sets correct headers for the differents browser and send the file
=end
class ExportController < ApplicationController

  # return the contents of contributions in a table in ODS format
  # with Ruport :
  # We can export to other formats :
  # compute_contributions(:pdf) export to pdf
  def contracts
    respond_to do |format|
      format.html { redirect_to contracts_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @issues.to_xml should be enough)
      }
      format.ods { compute_contracts(:ods) }
    end
  end

  def compute_contracts(type)
    methods = [ 'contract_name', 'start_date_formatted', 'end_date_formatted',
      'users_size', 'releases_size', 'issues_size', 'tam_name',
      'salesman_name', 'pname_teams', 'pname_users' ]
    options = { :order => 'contracts.start_date ASC',
      :include => [:salesman, :manager],
      :joins => 'INNER JOIN contracts_teams ct ON ct.contract_id=contracts.id',
      :conditions => flash[:conditions],
      :methods => methods }

    report = Contract.report_table(:all, options)
    columns= [ 'id', 'contract_name', 'start_date_formatted', 'end_date_formatted',
      'users_size', 'releases_size', 'issues_size', 'tam_name',
      'salesman_name', 'pname_teams', 'pname_users' ]
    unless report.column_names.empty?
      report.reorder(columns)
      report.rename_columns columns,
        [ _('id'), _('contract'), _('start date'), _('end date'), _('users'),
          _('softwares'), _('issues'), _('tam'), _('salesman'), _('teams'),
          _('users') ]
    end
    generate_report(report, type, {})
  end



  # return the contents of contributions in a table in ODS format
  # with Ruport :
  # We can export to other formats :
  # compute_contributions(:pdf) export to pdf
  def contributions
    respond_to do |format|
      format.html { redirect_to contributions_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @issues.to_xml should be enough)
      }
      format.ods { compute_contributions(:ods) }
    end
  end

  def compute_contributions(type)
    methods = ['pname_typecontribution', 'pname_software', 'version_to_s',
      'pname_etatreversement', 'delay_in_words', 'clos_enhance',
      'contributed_on_formatted']
    options = { :order => 'contributions.contributed_on ASC',
      :include => [:software, :etatreversement, :issue],
      :conditions => flash[:conditions],
      :methods => methods }

    report = Contribution.report_table(:all, options)
    columns= [ 'id','pname_typecontribution', 'pname_software',
      'version_to_s','pname_etatreversement', 'synthesis',
      'contributed_on_formatted','clos_enhance','delay_in_words' ]
    unless report.column_names.empty?
      report.reorder(columns)
      report.rename_columns columns,
        [ _('id'), _('type'), _('software'), _('version'), _('state'),
          _('summary'), _('reported'), _('closed'), _('delay') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of users in a table in ODS format
  # with Ruport
  def users
    respond_to do |format|
      format.html { redirect_to accounts_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @issues.to_xml should be enough)
      }
      format.ods { compute_users(:ods) }
    end
  end

  def compute_users(type)
    options = { :order => 'users.login', :include =>
      [:recipient,:ingenieur,:role], :conditions => flash[:conditions],
      :methods => ['recipient_client_name', 'role_name']
    }
    report = User.report_table(:all, options)
    columns = ['id','login','name','email','telephone',
      'recipient_client_name', 'role_name']

    report.reorder columns
    report.rename_columns columns,
      [_('id'), _('login'), _('name'), _('e-mail'), _('phone'),
        _('(customer)'), _('roles') ]

    generate_report(report, type, {})
  end

  # with Ruport:
  def phonecalls
    respond_to do |format|
      format.html { redirect_to phonecalls_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @issues.to_xml should be enough)
      }
      format.ods { compute_phonecalls(:ods) }
    end
  end

  def compute_phonecalls(type)
    columns= ['contract_name', 'ingenieur_name', 'recipient_name']
    options = { :order => 'phonecalls.start', :include =>
      [:recipient,:ingenieur,:contract,:issue],
      :conditions => flash[:conditions],
      :methods => columns }
    report = Phonecall.report_table(:all, options)

    columns.push( 'start','end')
    unless report.column_names.empty?
      report.reorder columns
      report.rename_columns columns,
        [ _('Contract'), _('Owner'), _('Customer'), _('Call'),
          _('End of the call') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of an issue in a table in  ods
  def issues
    respond_to do |format|
      format.html { redirect_to issues_path }
      format.xml {
        # TODO : make an xml export : a finder +
        #  render :xml => @issues.to_xml should be enough)
      }
      format.ods { compute_issues(:ods, {}) }
    end
  end

  def compute_issues(type, options_generate)
    columns = [ 'id', 'softwares_name', 'clients_name', 'severities_name',
      'created_on_formatted', 'socle', 'updated_on_formatted', 'resume',
      'statuts_name', 'typeissues_name', 'expert_name', 'last_comment_content', 'joined_tags'
    ]
    options = { :order => 'issues.created_on', :conditions => flash[:conditions],
      :select => Issue::SELECT_LIST + ', comments.text as last_comment_text',
      :joins => Issue::JOINS_LIST +
      ' INNER JOIN comments ON comments.id = issues.last_comment_id',
      :methods => columns
     }
    report = nil
    report = Issue.report_table(:all, options)
    unless report.column_names.empty?
      report.reorder columns
      report.rename_columns columns,
       [ _('Id'), _('Software'), _('Customer'), _('Severity'),
         _('Submission date') , _('Platform'), _('Last update'),
         _('Summary'), _('Status'), _('Type'), _('Assigned to'),
         _('Last comment'), _('Tags') ]
    end

    generate_report(report, type, options_generate)
  end


  MIME_EXTENSION = {
    :text => [ '.txt', 'text/plain' ],
    :csv  => [ '.csv', 'text/csv' ],
    :pdf  => [ '.pdf', 'application/pdf' ],
    :html => [ '.html', 'text/html' ],
    :ods  => [ '.ods', 'application/vnd.oasis.opendocument.spreadsheet']
  } unless defined? MIME_EXTENSION

  # Generate and upload a report to the user with a predefined name.
  #
  # Usage : generate_report(report, :csv) with report a Ruport Data Table
  def generate_report(report, type, options)
    #to keep the custom filters before the export :
    flash[:conditions] = flash[:conditions]
    file_extension = MIME_EXTENSION[type].first
    content_type = MIME_EXTENSION[type].last
    prefix = ( @recipient ? @recipient.client.name : App::ServiceName )
    suffix = Time.now.strftime('%d_%m_%Y')
    filename = [ prefix, params[:action], suffix].join('_') + file_extension

     #this is required if you want this to work with IE
     if request.env['HTTP_USER_AGENT'] =~ /msie/i
       headers['Pragma'] = 'public'
       headers['Content-type'] = content_type
       headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
       headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
       headers['Expires'] = "0"
     else
       headers["Content-type"] ||= content_type
       headers['Pragma'] = 'public'
       headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
     end
    report_out = report.as(type, options)
    render(:text =>report_out , :layout => false)
  end

  #export the comex table in ods
  def comex
    clients = flash[:clients]
    issues= flash[:issues]
    total = flash[:total]
    data = []
    row = ['', _('To be closed')+ " (I)",'','','',
      _('New issues'),'','','',
      _("Issues closed \n this week") + ' (IV)','','','',
      _("Total in progress \n end week") + ' (V=I+III-IV)','','','',
      _('TOTAL')
    ]
    data << row
    row = [_('Customer')]
    4.times do
      row += [_('Blocking'), _('Major'), _('Minor'), _('None')]
    end
    row << _('To close')
    data << row
    clients.each do |c|
      name = c.name.intern
      row = [name]
      repeat4times row,issues[:last_week][name],1
      repeat4times row,issues[:new][name],1
      repeat4times row,issues[:closed][name],1
      repeat4times row, total[:active][name],0
      row << total[:final][name]
      data << row
    end

    row = [_('TOTALS')]
    repeat4times row, issues[:last_week][:total],0
    repeat4times row, issues[:new][:total],0
    repeat4times row, issues[:closed][:total],0
    repeat4times row, total[:active][:total],0
    row << total[:final][:total]
    data << row

    report =  Table(:column_names => data[1], :data => data[2..-1])
    generate_report(report, :ods, {})

    flash[:clients]= flash[:clients]
    flash[:issues]= flash[:issues]
    flash[:total]= flash[:total]
  end

  private
  def repeat4times( row, element, decalage)
    4.times do |i|
      row << element[i+decalage].to_i
    end
  end

  # TODO : le mettre dans les utils ?
  def pname(object)
    (object ? object.name : '-')
  end

end
