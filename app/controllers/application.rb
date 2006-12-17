#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################

# Controller general de l'application
# Les filtres ajout�s � ce controller seront charg�s pour tous les autres.
# De m�me, toutes les m�thodes ajout�es ici seront disponibles.

# authentification
require_dependency "login_system"
# gestion des roles et des permissions
# en cas de soucis : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/versions/468
require_dependency "acl_system" 



class ApplicationController < ActionController::Base


  meantime_filter :scope_beneficiaire

  before_filter :set_charset
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # systems d'authentification 
  include LoginSystem
  include ACLSystem
  model :identifiant

  # layout standard
  layout "standard-layout"

  # variables globales
  def set_global_shortcuts
    # TODO : encore n�cessaire ? Non !!
    # groupe
    set_sessions unless @session[:filtres]
    @ingenieur = @session[:ingenieur]
    @beneficiaire = @session[:beneficiaire]
    @user_group = (@ingenieur ? 'ing�nieur' : 'b�n�ficiaire')

  end

  protected
  
  # variable utilisateurs; n�cessite @session[:user]
  def set_sessions
    return unless @session[:user]
    @session[:filtres] = Hash.new
    @session[:beneficiaire] = @session[:user].beneficiaire
    @session[:ingenieur] = @session[:user].ingenieur
    @session[:nav_links] = render_to_string :inline => "
        <% nav_links = [ 
        (link_to 'Accueil',:controller => 'bienvenue', :action => 'list'),
        (link_to 'D�connexion',:controller => 'account', :action => 'logout'), 
        (link_to 'Mon compte', :controller => 'account', :action => 'modify', :id => @session[:user].id),
        (link_to 'Plan',:controller => 'bienvenue', :action => 'plan'),
        (link_to 'Utilisateurs', :controller => 'account', :action => 'list')] %>
        <%= nav_links.compact.join(' | ') if @session[:user] %>"
    @session[:cut_links] = render_to_string :inline => "
        <% cut_links = [ 
        (link_to 'Demandes',:controller => 'demandes', :action => 'list'),
        (link_to 'Logiciels',:controller => 'logiciels', :action => 'list'),
        (link_to 'Projets',:controller => 'projets', :action => 'list'),
        (link_to 'T�ches',:controller => 'taches', :action => 'list'),
        (link_to 'Correctifs',:controller => 'correctifs', :action => 'list'),
        (link_to 'Paquets',:controller => 'paquets', :action => 'list'),
        (link_to 'R�pertoire',:controller => 'documents', :action => 'select')]%>
        <%= cut_links.compact.join(' | ') %>"
  end


  # encodage
  def set_charset
    @headers['Content-Type'] = 'text/html; charset=ISO-8859-1'
  end

  #scope
  def scope_beneficiaire
    yield
  end

private

  # notifie en cas d'erreur
  def log_error(exception)
    super
    Notifier::deliver_error_message(exception,
                                    clean_backtrace(exception),
                                    session.instance_variable_get("@data"),
                                    params,
                                    request.env)
  end

end



