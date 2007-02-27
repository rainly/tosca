#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

#Pour l'import de plusieurs utilisateurs
require 'fastercsv'

class AccountController < ApplicationController
  layout  'standard-layout'

  helper :ingenieurs, :beneficiaires

  #before_filter :login_required, :except => [:login]
  before_filter :verifie, :only => [ :modify, :update ]

  def index
    list
    render :action => 'list'
  end
 
  def verifie
    super(Identifiant)
  end

  def login
    set_sessions
    case request.method
      when :post
        if @session[:user] = Identifiant.authenticate(params['user_login'],
                                                      params['user_password'],
                                                      params['user_crypt'])
          set_sessions
          flash[:notice] = "Connexion réussie"
          flash[:notice] << '<br/>Javascript n\'est pas activé sur votre navigateur' unless @session[:javascript]
          redirect_back_or_default :action => "list", :controller => 'bienvenue'
        else
          @login = params['user_login']
          flash.now[:warn]  = "Echec lors de la connexion"
      end
    end
  end

  def devenir
    if @ingenieur
      benef = Beneficiaire.find(params[:id])
      session[:user] = benef.identifiant
      set_sessions
    else
      flash[:warn] = 'Vous n\'êtes pas autoriser à changer d\'identité'
    end
    redirect_to_home
  end

  def modify
    _form
    case request.method
    when :post
      @identifiant = Identifiant.find(params[:id])
      newIdentifiant = params[:identifiant]
      #on ne met pas à jour le mot de passe
      if newIdentifiant[:password] == ''
        newIdentifiant[:password] = @identifiant.password
        newIdentifiant[:password_confirmation] = @identifiant.password
      else
        if newIdentifiant[:password] != newIdentifiant[:password_confirmation]
          flash[:notice]  = "Les mots de passe que avez entrés sont différents."
          redirect_back_or_default :action => "modify", :controller => "account"
        else
          @identifiant.change_password(newIdentifiant[:password])
          newIdentifiant[:password] = @identifiant.password
        end
      end

      # pour update des roles accordéss

      @identifiant.roles = Role.find(params[:role_ids]) if params[:role_ids]

      if @identifiant.update_attributes(newIdentifiant)
        if session[:user] == @identifiant
          #On sauve bien notre profil
          clear_sessions
          session[:user] = @identifiant
          set_sessions
        end
        flash[:notice]  = "Modification réussie"
        redirect_back_or_default :action => "list", :controller => 'bienvenue'
      end
    when :get
      @identifiant = Identifiant.find(params[:id])
      @identifiant.password_confirmation = @identifiant.password
    end
  end

  def show
    @identifiant = Identifiant.find(params[:id])
  end

  #utilisé dans account/list
  def update
    @user = Identifiant.find(params[:id])
    # j'ai pas fait de vérification, ça plante
    # pour update des roles accordéss
    if params[:role_ids]
      @user.roles = Role.find(params[:role_ids])
    else
      @user.roles = []
      # @user.errors.add_on_empty('roles')
    end
    flash[:notice] = "L'utilisateur a bien été mis à jour."
    redirect_to :action => 'list'
  end

  def signup
    _form
    case request.method
    when :post
      @identifiant = Identifiant.new(params['identifiant'])
      if @params[:role_ids]
        @identifiant.roles = Role.find(params[:role_ids])
      else
        @identifiant.roles = []
        @identifiant.errors.add_on_empty('roles')
        render :action => 'signup'
        return
      end

      if @identifiant.save
        client = Client.find(params[:client][:id])
        flash[:notice] = "Enregistrement réussi, n'oubliez pas de vérifier son profil<br />"
        if @identifiant.client
          beneficiaire = Beneficiaire.new(:identifiant => @identifiant,
                                          :client => client)
          flash[:notice] += "Beneficiaire associé créé" if beneficiaire.save
        else
          ingenieur = Ingenieur.new(:identifiant => @identifiant)
          flash[:notice] += "Ingénieur associé créé" if ingenieur.save
        end
        Notifier::deliver_identifiant_nouveau({ :identifiant => @identifiant,
                                                :controller => self,
                                                :password => params[:identifiant][:password_confirmation]}, flash)

        redirect_back_or_default :action => "list"
      end
    when :get
      @identifiant = Identifiant.new
    end
  end

  def logout
    clear_sessions
    redirect_to "/"
  end

  # Format du fichier CSV
  # Nom complet, Titre, Email, Téléphone, Identifiant, Mot de passe, Informations
  # Nom complet	 Titre	Email	Téléphone	Identifiant	Mot de passe	Informations
  def multiple_signup
    _form
    @identifiant = Identifiant.new
    case request.method 
    when :post
      if(params['textarea_csv'].to_s.empty?)
        flash.now[:warn] = "Veuillez rentrer un texte sous format CSV"
        return
      #elsif TODO : tester si toutes les rows sont bien là
      #   row['Nom Complet'] && row['Titre'] && row['Email'] 
      #   && row['Téléphone'] && row['Identifiant'] && row['Mot de passe']
      #   && row['Mot de passe'] && row['Informations']
      #   && params[:identifiant] && params[:identifiant][:client]
      # flash.now[:warn] = "Le fichier CSV n'est pas bien formé"
      # return
      end

      flash[:notice] = ''
      flash.now[:warn] = ''

      FasterCSV.parse(params['textarea_csv'].to_s.gsub("\t", ";"), { :col_sep => ";", :headers => true }) do |row|
        @identifiant = Identifiant.new do |i|
           logger.debug(row.inspect)
           i.nom = row['Nom Complet'].to_s
           i.titre = row['Titre'].to_s
           i.email = row['Email'].to_s
           i.telephone = row['Téléphone'].to_s
           i.login = row['Identifiant'].to_s
           i.password = row['Mot de passe'].to_s
           i.password_confirmation = row['Mot de passe'].to_s
           i.informations = row['Informations'].to_s
           i.client = params[:identifiant][:client]
        end
        if params[:role_ids]
          @identifiant.roles = Role.find(params[:role_ids])
        else
          @identifiant.roles = []
          #@identifiant.errors.add_on_empty('roles')
          render :action => 'multiple_signup'
          return
        end
        if @identifiant.save
          client = Client.find(params[:client][:id])
          flash[:notice] += "L'utilisateur " + row['Nom Complet'].to_s + " a bien été créé.<br/>"
          if @identifiant.client
            beneficiaire = Beneficiaire.new(:identifiant => @identifiant, :client => client)
            flash[:notice] += "Bénéficiaire associé créé" if beneficiaire.save
          else
            ingenieur = Ingenieur.new(:identifiant => @identifiant)
            flash[:notice] += "Ingénieur associé créé" if ingenieur.save
          end
          Notifier::deliver_identifiant_nouveau({ :identifiant => @identifiant,
                                                  :controller => self,
                                                  :password => row['Mot de passe'].to_s}, flash)
          flash[:notice] += "<br/>"
        else
          flash.now[:warn] += "L'utilisateur " + row['Nom Complet'].to_s + " n'a pas été créé.<br/>"
        end
      end
      redirect_back_or_default :action => "list"
    when :get
    end
  end

  def list
    @roles = Role.find(:all)
    scope_filter do
      @user_pages, @users = paginate :identifiants, :per_page => 25,
      :order => 'identifiants.login', :include => 
        [:beneficiaire,:ingenieur,:roles]
    end
  end

  def destroy
    Identifiant.find(params[:id]).destroy
    redirect_to_home
  end


private

  def _form
    @roles = Role.find(:all)
    @clients = Client.find(:all)
  end

  # variable utilisateurs; nécessite session[:user]
  # penser à mettre à jour les pages statiques 404 
  # et 500 en cas de modification
  def set_sessions
    return unless session[:user]
    session[:filters] = Hash.new
    session[:beneficiaire] = session[:user].beneficiaire
    session[:ingenieur] = session[:user].ingenieur
    session[:javascript] = ( params['javascript'] == "true" ? true : false )
    session[:nav_links] = render_to_string :inline => "
        <% nav_links = [ 
          (link_to 'Accueil',:controller => 'bienvenue', :action => 'list'),
          (link_to 'Déconnexion',:controller => 'account', :action => 'logout'), 
          (link_to_modify_account(session[:user], 'Mon compte')),
          (link_to 'Plan',:controller => 'bienvenue', :action => 'plan'),
          (link_to 'Utilisateurs', :controller => 'account', :action => 'list'),
          (link_to 'Rôles', :controller => 'roles', :action => 'list')
        ] %>
        <%= nav_links.compact.join('&nbsp;|&nbsp;') if session[:user] %>"
    session[:cut_links] = render_to_string :inline => "
        <% cut_links = [ 
          (link_to 'Demandes',:controller => 'demandes', :action => 'list') " +
          (session[:user].authorized?('demandes/list') ? "+ '&nbsp;' + search_demande," : ',' ) + 
         "(link_to 'Logiciels',:controller => 'logiciels', :action => 'list'),
          (link_to 'Projets',:controller => 'projets', :action => 'list'),
          (link_to 'Tâches',:controller => 'taches', :action => 'list'),
          (link_to 'Contributions',:controller => 'contributions', :action => 'list'),
          (link_to 'Répertoire',:controller => 'documents', :action => 'select'), 
          (link_to_my_client), 
          (link_to 'Clients',:controller => 'clients', :action => 'list')
        ] %>
        <% form_tag(:controller => 'demandes', :action => 'list') do %>
        <%= cut_links.compact.join('&nbsp;|&nbsp;') %>
        <% end %>"
  end


  # efface les paramètres de session
  def clear_sessions
    @session[:user] = nil
    @session[:beneficiaire] = nil
    @session[:ingenieur] = nil
    @session[:logo_08000] = nil
    @session[:filtres] = nil
    @beneficiaire = nil
    @ingenieur = nil
  end


  def scope_beneficiaire
    if @beneficiaire
      conditions = [ "identifiants.id = ?", @beneficiaire.identifiant_id ]
      Identifiant.with_scope({ :find => {:conditions => conditions} }) { yield }
    else
      yield
    end
  end

end
