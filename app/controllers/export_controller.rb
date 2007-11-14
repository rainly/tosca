#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

#require 'fastercsv'
# generate CSV files for download
# send formatted output directly to the HTTP response
# source : http://wiki.rubyonrails.org/rails/pages/HowtoExportDataAsCSV
class ExportController < ApplicationController

  # return the contents of identifiants in a table in ODS format
  # with Ruport :
  # We can export to other formats : 
  # compute_contributions(:pdf) export to pdf
  def contributions
    respond_to do |format|
      format.html { redirect_to contributions_path }
      format.xml {
        # TODO : make an xml export : a finder + 
        #  render :xml => @requests.to_xml should be enough) 
      }
      format.ods { compute_contributions(:ods) }
    end
  end

  def compute_contributions(type)
    methods = ['pnom_typecontribution', 'pnom_logiciel', 'version_to_s',
      'pnom_etatreversement', 'delai_in_french_words', 'clos_enhance',
      'reverse_le_formatted']
    options = { :order => 'contributions.reverse_le ASC',
      :include => [:logiciel, :etatreversement, :demandes],
      :conditions => flash[:conditions],
      :methods => methods }

    report = Contribution.report_table(:all, options)
    columns= [ 'id','pnom_typecontribution', 'pnom_logiciel',
      'version_to_s','pnom_etatreversement', 'synthese',
      'reverse_le_formatted','clos_enhance','delai_in_french_words' ]
    unless report.column_names.empty?
      report.reorder(columns) 
      report.rename_columns columns,
        [ _('id'), _('type'), _('software'), _('version'), _('state'),
          _('summary'), _('reported'), _('closed'), _('delay') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of identifiants in a table in ODS format
  # with Ruport
  def identifiants
    respond_to do |format|
      format.html { redirect_to identifiants_path }
      format.xml { 
        # TODO : make an xml export : a finder + 
        #  render :xml => @requests.to_xml should be enough) 
      }
      format.ods { compute_identifiants(:ods) }
    end
  end

  def compute_identifiants(type)
    options = { :order => 'identifiants.login', :include => 
      [:beneficiaire,:ingenieur,:role], :conditions => flash[:conditions],
      :methods => ['beneficiaire_client_nom', 'role_nom']
    }
    report = Identifiant.report_table(:all, options)
    columns = ['id','login','nom','email','telephone',
      'beneficiaire_client_nom', 'role_nom']

    report.reorder columns
    report.rename_columns columns,
      [_('id'), _('login'), _('name'), _('e-mail'), _('phone'),
        _('(customer)'), _('roles') ]

    generate_report(report, type, {})
  end

  # with Ruport:
  def appels
    respond_to do |format|
      format.html { redirect_to appels_path }
      format.xml { 
        # TODO : make an xml export : a finder + 
        #  render :xml => @requests.to_xml should be enough) 
      }
      format.ods { compute_appels(:ods) }
    end
  end

  def compute_appels(type)
    columns= ['contrat_nom', 'ingenieur_nom', 'beneficiaire_nom']
    options = { :order => 'appels.debut', :include => 
      [:beneficiaire,:ingenieur,:contrat,:demande], 
      :conditions => flash[:conditions],
      :methods => columns }
    report = Appel.report_table(:all, options)

    columns.push( 'debut','fin')
    unless report.column_names.empty?
      report.reorder columns 
      report.rename_columns columns,
        [ _('Contract'), _('Owner'), _('Customer'), _('Call'), 
          _('End of the call') ]
    end
    generate_report(report, type, {})
  end

  # return the contents of a request in a table in  ods
  def requests
    respond_to do |format|
      format.html { redirect_to demandes_path }
      format.xml { 
        # TODO : make an xml export : a finder + 
        #  render :xml => @requests.to_xml should be enough) 
      }
      format.ods { compute_demandes(:ods, {}) }
    end
  end

  def compute_demandes(type, options_generate)
    columns = [ 'id', 'logiciels_nom', 'clients_nom', 'severites_nom',
      'created_on_formatted', 'socle', 'updated_on_formatted', 'resume', 
      'statuts_nom', 'typedemandes_nom'
    ]
    options= { :order => 'updated_on DESC', :conditions => flash[:conditions],
      :select => Demande::SELECT_LIST, :joins => Demande::JOINS_LIST,
      :methods => columns
     }
    report = nil
    Demande.without_include_scope(@ingenieur, @beneficiaire) do
      report = Demande.report_table(:all, options)
    end
    unless report.column_names.empty?
      report.reorder columns
      report.rename_columns columns,
       [ _('Id'), _('Software'), _('Customer'), _('Severity'),
         _('Submission date') , _('Platform'), _('Last update'),
         _('Summary'), _('Status'), _('Type') ]
    end

    generate_report(report, type, options_generate)
  end


  MIME_EXTENSION = { 
    :text => [ '.txt', 'text/plain' ],
    :csv  => [ '.csv', 'text/csv' ],
    :pdf  => [ '.pdf', 'application/pdf' ],
    :html => [ '.html', 'text/html' ],
    :ods  => [ '.ods', 'application/vnd.oasis.opendocument.spreadsheet']
  }

  # Generate and upload a report to the user with a predefined name.
  #
  # Usage : generate_report(report, :csv) with report a Ruport Data Table
  def generate_report(report, type, options)
    #to keep the custom filters before the export :
    flash[:conditions] = flash[:conditions]
    file_extension = MIME_EXTENSION[type].first
    content_type = MIME_EXTENSION[type].last
    prefix = ( @beneficiaire ? @beneficiaire.client.nom : 'OSSA' )
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
    requests= flash[:requests]
    total = flash[:total]
    data = []
    row = ['', _('To be closed')+ " (I)",'','','',
      _('New requests'),'','','',
      _("Requests closed \n this week") + ' (IV)','','','',
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
      name = c.nom.intern
      row = [name]
      repeat4times row,requests[:last_week][name],1
      repeat4times row,requests[:new][name],1
      repeat4times row,requests[:closed][name],1
      repeat4times row, total[:active][name],0 
      row << total[:final][name]
      data << row
    end

    row = [_('TOTALS')]
    repeat4times row, requests[:last_week][:total],0 
    repeat4times row, requests[:new][:total],0 
    repeat4times row, requests[:closed][:total],0 
    repeat4times row, total[:active][:total],0 
    row << total[:final][:total]
    data << row

    report = data.to_table 
    generate_report(report, :ods, {})

    flash[:clients]= flash[:clients]
    flash[:requests]= flash[:requests]
    flash[:total]= flash[:total]
  end

  private
  def repeat4times( row, element, decalage)
    4.times do |i|
      row << element[i+decalage].to_i
    end
  end

  # TODO : le mettre dans les utils ?
  def pnom(object)
    (object ? object.nom : '-')
  end

end
