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
class ContributionsController < ApplicationController
  helper :issues, :versions, :hyperlinks, :softwares

  cache_sweeper :contribution_sweeper, :only => [ :create, :update ]

  def index
    select
    render :action => "select"
  end

  def list
    options = { :order => "contributions.created_on DESC", :page => params[:page] }
    options[:conditions] = { }
    unless params[:id] == 'all'
      @software = Software.find(params[:id])
      options[:conditions] = { :software_id => @software.id }
    end
    client_id = params[:client_id].to_s
    unless client_id.blank?
      options[:conditions].merge!({'contracts.client_id' => params[:client_id]})
      options[:include] = {:issue => :contract}
    end
    @contributions = Contribution.paginate options
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def select
    client_id = params[:client_id].to_s
    unless read_fragment "contributions/select_#{client_id || 'all'}"
      options = { :order => 'softwares.name ASC' }
      options[:joins] = :contributions
      options[:select] = 'DISTINCT softwares.*'
      unless client_id.blank?
        options[:conditions] = { 'contracts.client_id' => params[:client_id] }
        options[:joins] = { :contributions => { :issue => :contract } }
      end
      @softwares = Software.all(options)
    end
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC',
      :include => [:software,:contributionstate,:issue], :page => params[:page] }

    if params.has_key? :filters
      session[:contributions_filters] =
        Filters::Contributions.new(params[:filters])
    end
    conditions = nil
    contributions_filters = session[:contributions_filters]
    if contributions_filters
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(contributions_filters, [
        [:software, 'softwares.name', :like ],
        [:contribution, 'contributions.name', :like ],
        [:contributionstate_id, 'contributions.contributionstate_id', :equal ],
        [:engineer_id, 'contributions.engineer_id', :equal ],
        [:contract_id, 'issues.contract_id', :equal ]
      ])
      @filters = contributions_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @contributions = Contribution.paginate options
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_panel = 'admin_panel'
    end
  end

  def new
    @contribution = Contribution.new
    # we can precise the software with this, see software/show for more info
    @contribution.software_id = params[:software_id]
    # submitted state, by default
    @contribution.contributionstate_id = 4
    @contribution.contributed_on = Date.today
    @issue = Issue.new; @issue.id = params[:issue_id]
    @contribution.engineer = @session_user
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if _link2issue && @contribution.save
      flash[:notice] = _('The contribution has been created successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contribution = Contribution.find(params[:id])
    _form
  end

  def show
    @contribution = Contribution.find(params[:id])
  end

  def update
    @contribution = Contribution.find(params[:id])
    if _link2issue && @contribution.update_attributes(params[:contribution])
      flash[:notice] = _('The contribution has been updated successfully.')
      _update(@contribution)
      redirect_to contribution_path(@contribution)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contribution.find(params[:id]).destroy
    redirect_to contributions_path
  end

  def ajax_list_versions
    return render(:nothing => true) unless request.xhr?
    begin
      soft = Software.find(params[:software_id])
      @versions = soft.versions.find_select
    rescue # mainly if software is not findable or software_id.nil?
      render(:nothing => true)
    end
  end

private
  def _form
    @softwares = Software.find_select
    @contributionstates = Contributionstate.find_select
    @engineers = User.find_select(User::EXPERT_OPTIONS)
    @contributiontypes = Contributiontype.find_select
    if @contribution.software_id
      @versions = @contribution.software.versions.find_select
    else
      @versions = [] # Version.all.find_select
    end
  end

  def _panel
    @contributionstates = Contributionstate.find_select
    @engineers = User.find_select(User::EXPERT_OPTIONS)
    @softwares = Software.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
    # count
    csoftwares = { :select => 'contributions.software_id', :distinct => true }
    @count = {:contributions => Contribution.count,
      :softwares => Contribution.count(csoftwares) }
  end

  def _update(contribution)
    url = params[:hyperlink]
    contribution.hyperlinks.create(url) unless url.blank?
    contribution.contributed_on = nil if params[:contribution][:reverse] == '0'
    contribution.closed_on = nil if params[:contribution][:clos] == '0'
    contribution.save
  end

  def _link2issue
    begin
      issue = Issue.find(params[:issue][:id].to_i) unless params[:issue][:id].blank?
      @contribution.issue = issue
      true
    rescue
      flash[:warn] = _('The associated issue does not exist')
      false
    end
  end
end
