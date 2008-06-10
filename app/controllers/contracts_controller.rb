class ContractsController < ApplicationController
  helper :clients,:engagements,:ingenieurs

  def index
    @contract_pages, @contracts = paginate :contracts, :per_page => 25
  end

  # Used to know which contracts need to be renewed
  def actives
    options = { :per_page => 10, :include => [:client], :order =>
      'contracts.cloture', :conditions => 'clients.inactive = 0' }
    @contract_pages, @contracts = paginate :contracts, options
    render :action => 'index'
  end


  def show
    @contract = Contract.find(params[:id])
    @teams = @contract.teams
  end

  def new
    # It is the default contract
    @contract = Contract.new
    @contract.client_id = params[:id]
    @contract.rule_type = 'Rules::Component'
    _form
  end

  def ajax_choose
    value = params[:value]
    render :nothing => true and return unless request.xhr? && !value.blank?
    @rules = []
    if value.grep(/^Rules::/) # H@k3rz protection
      @rules = value.constantize.find_select
    end
    @type = 'rules' unless @rules.empty?
  end

  def create
    Client.send(:with_exclusive_scope) do
      @contract = Contract.new(params[:contract])
    end
    @contract.creator = session[:user]
    if @contract.save
      flash[:notice] = _('Contract was successfully created.')
      redirect_to contracts_path
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @contract = Contract.find(params[:id])
    _form
  end

  def update
    @contract = Contract.find(params[:id])
    @contract.creator = session[:user] unless @contract.creator
    if @contract.update_attributes(params[:contract])
      flash[:notice] = _('Contract was successfully updated.')
      redirect_to contract_path(@contract)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contract.find(params[:id]).destroy
    redirect_to contracts_path
  end

private
  def _form
    # Needed in order to be able to auto-associate with it
    Client.send(:with_exclusive_scope) do
      @clients = Client.find_select
    end
    @engagements = Engagement.find(:all, Engagement::OPTIONS)
    @ingenieurs = User.find_select(User::EXPERT_OPTIONS)
    @teams = Team.find_select
    @contract_team = @contract.teams
    @rules = []
    begin
      @rules = @contract.rule_type.constantize.find_select
    rescue Exception => e
      flash[:warn] = _('Unknown rules for contract "%s"') % e.message
    end
  end

end
