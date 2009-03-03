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

class AccountController < ApplicationController
  helper :knowledges, :contracts, :issues

  cache_sweeper :user_sweeper, :only => [:signup, :update]

  include PasswordGenerator

  # No clear text password in the log.
  # See http://api.rubyonrails.org/classes/ActionController/Base.html#M000441
  filter_parameter_logging :password

  helper :roles

  # There's no need to check login on those actions
  skip_before_filter :login_required, :only => [:login, :logout]

  # Only available with POST, see config/routes.rb
  def login
    case request.method
    when :post
      # For automatic login from an other web tool,
      # password is provided already encrypted
      user = User.authenticate(params['user_login'], params['user_password'])
      if user
        _login(user)
        redirect_back_or_default welcome_path
      else
        clear_sessions
        id = User.find_by_login(params['user_login'])
        flash.now[:warn] = _("Connexion failure")
        flash.now[:warn] += _(", your account has been desactivated") if id and id.inactive?
      end
    else # Display form
    end
  end

  # Exit gracefully
  def logout
    theme, last_user = session[:theme], session[:last_user]
    clear_sessions
    # preserve theme, what ever happens
    session[:theme] = theme

    # in case of "su" style use, relog to previous one
    _login(last_user) if last_user
    redirect_to "/"
  end

  def new
    redirect_to signup_new_account_path
  end

  # It's a bi-directionnal method, which display and process the form
  def signup
    case request.method
    when :get # Display form
      @user = User.new(:role_id => 4, :client_id => 0) # Default : customer
      _form
    when :post # Process form
      @user = User.new(params[:user])
      @user.generate_password # from PasswordGenerator, see lib/
      _associate_user
      if @user.save
        # The commit has to be after sending email, not before
        flash[:notice] = _("Account successfully created.")
        flash[:notice] += message_notice(@user.email, nil)
        redirect_to account_path(@user)
      else
        _form
      end
    end
  end

  def show
    @user = User.find(params[:id])
    _form
  end

  # TODO : Change ajax filter from client_id to contract_id, with
  # adequate changes in the Finder and in the Test Suite
  # TODO : this method is too long
  def index
    options = { :per_page => 15, :order => 'users.role_id, users.login',
      :include => [:role], :page => params[:page] }
    conditions = []
    @roles = Role.find_select

    if params.has_key? :filters
      session[:accounts_filters] = Filters::Accounts.new(params[:filters])
    end
    conditions = nil
    accounts_filters = session[:accounts_filters]
    if accounts_filters
      # Specification of a filter f :
      # [ namespace, field, database field, operation ]
      conditions = Filters.build_conditions(accounts_filters, [
        [:name, 'users.name', :like ],
        [:client_id, 'users.client_id', :equal ],
        [:role_id, 'users.role_id', :equal ]
      ])
      flash[:conditions] = options[:conditions] = conditions
      @filters = accounts_filters
    end

    # Experts does not need to be scoped on accounts, but they can filter
    # only on their contract.
    scope = {}
    if @session_user.recipient?
      scope = User.get_scope(@session_user.contract_ids)
    end
    User.send(:with_scope, scope) do
      @users = User.paginate options
    end
    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_panel = 'index_panel'
    end
  end

  def edit
    @user = User.find(params[:id])
    _form
  end

  def update
    @user = User.find(params[:id])

    # Security Wall
    if @session_user.role_id > 2 # Not a manager nor an admin
      params[:user].delete :role_id
      params[:user].delete :contract_ids
    end

    res = @user.update_attributes(params[:user])
    if res and @user.recipient?
      res &= @user.update_attributes(params[:user_recipient])
    end
    if res and @user.engineer?
      res &= @user.update_attributes(params[:user_engineer])
    end
    if res # update of account fully ok
      set_sessions @user if @session_user == @user
      flash[:notice]  = _("Edition succeeded")
      redirect_to account_path(@user)
    else
      # Don't write this :  _form and render :action => 'edit'
      # Else, tosca returns an error. It don't find the template
      _form
      render(:action => 'edit')
    end
  end

  def forgotten_password
    if request.method == :post
      user = params[:user]
      return unless user && user.has_key?(:email) && user.has_key?(:login)
      flash[:warn] = _('Unknown account')
      conditions = { :email => user[:email], :login => user[:login] }
      @user = User.first(:conditions => conditions)
      return unless @user
      if @user.generate_password and @user.save
        flash[:warn] = nil
        flash[:notice] = _('Your new password has been generated.')
        #TODO : find a way to put it in the model user
        Notifier::deliver_user_signup(@user)
      end
    end
  end

  # Let an Engineer become a client user
  def become
    begin
      if @session_user.engineer?
        current_user = @session_user
        set_sessions(User.find(params[:id]))
        session[:last_user] = current_user
      else
        flash[:warn] = _('You are not allowed to change your identity')
      end
      redirect_to_home
    rescue ActiveRecord::RecordNotFound
      flash[:warn] = _('Person not found')
      redirect_to_home
    end
  end

  # Used during creation to display engineer or recipient form
  def ajax_place
    return render(:nothing => true) unless request.xhr? and params.has_key? :client
    @user = User.new
    @user.client_id = (params[:client] == 'true' ? 0 : nil)
    _form
  end

  # Used to list contracts during creation/edition
  def ajax_contracts
    if !request.xhr? || !params.has_key?(:client_id)
      return render(:nothing => true)
    end

    client_id = params[:client_id].to_i
    user_id = (params.has_key?(:id) ? params[:id].to_i : nil)
    options = Contract::OPTIONS
    conditions = [ 'contracts.end_date >= ?', Time.now]
    unless client_id == 0
      conditions.first << ' AND contracts.client_id = ?'
      conditions.push(client_id)
    end
    options = options.dup.update(:conditions => conditions)
    @contracts = Contract.find_select(options)
    @user = (user_id.blank? ? User.new : User.find(user_id))
  end


private
  def _login(user)
    set_sessions(user)
    flash[:notice] = (_("Welcome %s %s") %
                      [ user.title, user.name]).gsub(' ', '&nbsp;')

    user.active_contracts.each do |c|
      if (c.end_date - Time.now).between?(0.month, 1.month)
        message = '<br/><strong>'
        message << '</strong>'
        message << (_("Your contract '%s' is near its end date : %s") %
            [c.name, c.end_date_formatted])
        flash[:notice] << message
      end
    end
  end

  # Used to restrict operation
  #  One cannot edit account of everyone
  def authorize?(user)
    if params.has_key? :id
      id = params[:id].to_i
      # Only admins & manager can edit other accounts
      if user.role_id > 2 && id != user.id && action_name =~ /(edit|update)/
        return false
      end
    end
    super(user)
  end

  # Partial variables used in forms
  def _form
    conditions = (@user.engineer? ?
                  [ 'roles.id BETWEEN ? AND 3', @session_user.role_id ] :
                  'roles.id BETWEEN 4 AND 5')
    options = { :order => 'id', :conditions => conditions }
    @roles = Role.find_select(options)
    _form_recipient; _form_engineer
  end

  def _form_recipient
    return unless @user.recipient?
    @clients = Client.find_select
    @user.role_id = 4 if @user.new_record?
  end

  def _form_engineer
    return unless @user.engineer?
    @competences = Skill.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
    # For usability matters, list of checkable own_contracts
    # won't contains any already available by the team.
    @contracts -= @user.team.contracts.find_select(Contract::OPTIONS) if @user.team
    @clients = [Client.new(:id => 0, :name => '» ')].concat(Client.find_select)
    @user.role_id = 3 if @user.new_record?
  end

  def _panel
    if @session_user.role_id <= 2
      @count = {}
      @clients = Client.find_select

      @count[:users] = User.count
      @count[:recipients] = User.recipients.size
      @count[:engineers] = User.engineers.size
    end
  end

  # session variables, needs @session_user
  # DO NOT forget to check 404 & 500 error pages if you change this method
  def set_sessions(user)
    return_to, theme = session[:return_to], session[:theme]

    # clear_session erase @session_user
    clear_sessions

    # restoring previously consulted page
    session[:return_to], session[:theme] = return_to, theme

    # Set user properties
    session[:user] = user
  end

  # Used during login and logout
  def clear_sessions
    reset_session
  end

  # Used during signup, It saves the associated recipient/expert
  # Put in a separate method in order to improve readiblity of the code
  def _associate_user
    if params[:user][:client_form] == 'false'
      @user.associate_engineer
    elsif params.has_key? :user_recipient
      @user.associate_recipient(params[:user_recipient][:client_id])
    end
  end


  # Bulk import users
  # of improvements possibility. It's deactivated for now, until
  # someone find some times in order have it work properly
  # require 'fastercsv'

end
