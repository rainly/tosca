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
class ContractsController < ApplicationController
  helper :clients, :commitments, :versions, :issues, :subscriptions, :dates,
    :account

  auto_complete_for :user, :name, :contract, :engineer_user,
                    :conditions => 'client_id IS NULL'

  def index
    options = { :per_page => 25, :include => [:client],
      :order => 'contracts.client_id', :page => params[:page] }

    if params.has_key? :filters
      session[:contracts_filters] = Filters::Contracts.new(params[:filters])
    end

    conditions = nil
    contracts_filters = session[:contracts_filters]
    if contracts_filters
      # we do not want an include since it's only for filtering.
      unless contracts_filters['team_id'].blank?
        options[:joins] = Contract::INNER_JOIN_TEAMS
      end
      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(contracts_filters, [
        [:text, 'clients.name', 'contracts.name', :multiple_like],
        [:tam_id, 'contracts.tam_id', :equal],
        [:team_id, 'ct.team_id', :equal]
      ])
      @filters = contracts_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    @contracts = Contract.paginate options

    # panel on the left side.
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_panel = 'index_panel'
    end
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :page => params[:page],
      :order => 'contracts.end_date', :conditions => ['clients.inactive = ?', false] }
    @contracts = Contract.paginate options
    render :action => 'index'
  end

  def show
    @contract = Contract.find(params[:id])
  end

  # TODO : maybe the model is a better place for this ?
  def renew
    old_contract = Contract.find(params[:id])
    new_contract = Contract.new(old_contract.attributes)
    new_contract.save! # needed for hbtm relationships safety
    new_contract.users = old_contract.users;
    new_contract.teams = old_contract.teams
    new_contract.commitments = old_contract.commitments
    new_contract.versions = old_contract.versions
    new_contract.start_date = old_contract.end_date;
    new_contract.end_date = old_contract.end_date + (old_contract.end_date - old_contract.start_date)
    old_year, new_year = old_contract.start_date.year.to_s, new_contract.start_date.year.to_s
    if old_contract.name.grep(/#{old_year}/)
      new_contract.name = old_contract.name.gsub(old_year, new_year)
    else
      new_contract.name = "#{old_contract.name} #{new_year}"
    end
    new_contract.name = new_contract.start_date.year.to_s
    new_contract.save
    @contract = new_contract
    redirect_to edit_contract_path(@contract)
  end

  def new
    # TODO : put default contract into a config yml file ?
    @contract = Contract.new(:client_id => params[:client_id],
                             :rule_type => 'Rules::Component',
                             :opening_time => 9, :closing_time => 18)
    _form
  end

  def ajax_choose_rule_type
    value = params[:value]
    render :nothing => true and return unless request.xhr? && !value.blank?
    @rules = []
    if value.grep(/^Rules::/) # H@k3rz protection
      @rules = value.constantize.find_select
    end
    @type = 'rules' unless @rules.empty?
  end

  def create
    _aggregate_commitments
    # It's needed because manager are scoped, at this point
    Client.send(:with_exclusive_scope) do
      @contract = Contract.new(params[:contract])
      @contract.creator = @session_user
      # Due to a limitation of Rails <= 2.1, we cannot create a full
      # association in one pass.
      # TODO : review this problem on a > Rails
      engineers =  @contract.engineer_users.dup
      @contract.engineer_users = []
      if @contract.save
        @contract.update_attribute :engineer_users, engineers
        flash[:notice] = _('Contract was successfully created.')
        @contract.reload
        Notifier::deliver_contract_new @contract
        redirect_to contracts_path
      else
        @contract.engineer_users = engineers
        _form and render :action => 'new'
      end
    end
  end

  def edit
    @contract = Contract.find(params[:id])
    _form
  end

  def update
    @contract = Contract.find(params[:id])

    # need a real copy of all content of the contract,
    # not only its attributes and references
    old_contract = @contract.to_hash

    @contract.creator = @session_user unless @contract.creator
    _aggregate_commitments
    if @contract.update_attributes(params[:contract])
      flash[:notice] = _('Contract was successfully updated.')
      @contract.reload
      Notifier::deliver_contract_update(@session_user, @contract, ( @contract - old_contract ))
      redirect_to contract_path(@contract)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contract.find(params[:id]).destroy
    redirect_to contracts_path
  end

  def ajax_add_software
    selected = params[:select]
    if selected.blank? || !selected.has_key?(:software)
      return render(:nothing => true)
    end
    @software = Software.find(selected[:software])
    render(:update) { |page|
      page.insert_html(:before, "end", :partial => "software")
      page.visual_effect(:appear, @random_id)
    }
  end

  def supported_software
    @contract = Contract.find(params[:id]) unless @contract
    ordered_by_software = { :include => [:software], :order =>
      'softwares.name ASC, versions.name DESC' }
    @versions = @contract.versions.all(ordered_by_software)
    @softwares = Software.find_select
  end

  def add_software
    @contract = Contract.find(params[:id])
    software = params['software'] || []
    versions = []
    software.each do |s|
      # get rid of the random_field hack
      s = s[1]
      next unless s.is_a? Hash

      # We have to re-interprete this param,
      # because rails does not on a find
      s['generic'] = (s['generic'] == "true")

      # It's 2 lines but fast find_or_create call
      version = Version.first(:conditions => s)
      version = Version.create(s) unless version
      versions << version if version.valid?
    end
    @contract.versions = versions
    if @contract.save
      redirect_to contract_path(@contract)
    else
      supported_software and render :action => supported_software
    end
  end

  def tags
    @contract = Contract.find(params[:id])
    # We get the tags only for this contract
    @tags = Issue.tag_counts(:conditions => { :contract_id => @contract.id })
    if params[:tag] and not params[:tag].empty?
      tags = params[:tag].split(",")
      @issues = Issue.find_tagged_with(tags,
        :conditions => { :contract_id => @contract.id })
      @tag_with = tags
    end
  end

  def ajax_subscribe
    _ajax(Subscription.create(:user => @session_user,
                              :model => Contract.find(params[:id])))
  end

  def ajax_unsubscribe
    _ajax(Subscription.destroy_by_user_and_model(@session_user,
                                                 Contract.find(params[:id])))
  end

private
  def _ajax(test)
    status = (test ? :ok : :bad_request)
    show
    render :partial => 'subscribers', :status => status
  end

  def _form
    # Needed in order to be able to auto-associate with it
    Client.send(:with_exclusive_scope) do
      @clients = Client.find_select
    end
    @commitments = Commitment.all(Commitment::OPTIONS)
    @engineers = User.find_select(User::EXPERT_OPTIONS)
    @teams = Team.find_select
    @contract_team = @contract.teams
    @rules = []
    begin
      @rules = @contract.rule_type.constantize.find_select
    rescue Exception => e
      flash[:warn] = _('Unknown rules for contract "%s"') % e.message
    end
  end

  # Since Html lack of aggregation between multiple select, we have to do it
  # manually. It's a shame, and it's quite slow.
  # TODO : find a better way
  def _aggregate_commitments
    contract, ids = params[:contract], []
    return unless contract
    contract.keys.grep(/^commitment_ids/).each{|k|
      value = contract.delete(k)
      ids << value unless value == '0'
    }
    contract[:commitment_ids] = ids
  end

  def _panel
    @tams = User.tams
    @teams = Team.find_select
  end

end
