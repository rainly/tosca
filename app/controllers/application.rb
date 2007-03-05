#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Controller general de l'application
# Les filtres ajoutés à ce controller seront chargés pour tous les autres.
# De même, toutes les méthodes ajoutées ici seront disponibles.

# authentification
require_dependency "login_system"
# gestion des roles et des permissions
# en cas de soucis : http://wiki.rubyonrails.com/rails/pages/LoginGeneratorACLSystem/versions/468
require_dependency "acl_system" 

class ApplicationController < ActionController::Base
  around_filter :scope_beneficiaire
  helper :filters

  before_filter :set_headers
  before_filter :set_global_shortcuts
  before_filter :login_required, :except => [:refuse, :login]

  # systems d'authentification 
  include LoginSystem
  include ACLSystem

  # layout standard
  layout "standard-layout"

  # variables globales (beurk, mais tellement pratique ;))
  def set_global_shortcuts
    @ingenieur = session[:ingenieur]
    @beneficiaire = session[:beneficiaire]
  end


protected
   
  # redirection à l'accueil
  # TODO : certain redirect_to_home devrait etre redirect_back
  # TODO : faire une route nommée, c'est pas railsien cette fonction
  def redirect_to_home
    redirect_to :controller => 'bienvenue', :action => "list"
  end
 
  # redirection par défaut en cas d'erreur / de non droit
  def redirect_back
    redirect_back_or_default :controller => 'bienvenue', :action => "list"
  end

  def set_headers
    headers['Content-Type'] = ( request.xhr? ? 'text/javascript; charset=utf-8' : 
                                               'text/html; charset=utf-8' )
  end

  # verifie :
  # - s'il il y a un id en paramètre (sinon :  retour à la liste)
  # - si un ActiveRecord ayant cet id existe (sinon : erreur > rescue > retour à la liste)
  # options
  # :controller en cas de redirection (bienvenue)
  # :action en cas de redirection (list)
  # TODO : trop de copier-coller 
  # NOTODO : "options[:controller] = controller_name" par défaut
  #       c'est idéal, mais les clients n'ont pas les droits sur tous les */list
  #       on tombe alors sur un acces/refuse, dommage
  def verifie(ar, options = {:controller => 'bienvenue', :action => 'list'})
    if !params[:id]
      flash.now[:warn] = 'Veuillez préciser l\'identifiant de la demande à consulter.'
      redirect_to(options) and return false
    end
    scope_beneficiaire {
      object = ar.find(params[:id], :select => 'id') 
      if object = nil
        flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
        redirect_to(options) and return false
      end
    }
    true
  rescue  ActiveRecord::RecordNotFound
    flash.now[:warn] = "Aucun(e) #{ar.to_s} ne correspond à l'identifiant #{params[:id]}."
    redirect_to(options) and return false
  end

  # overriding for escaping count of include (eager loading)
  def count_collection_for_pagination(model, options)
    count_options = { :joins => options[:joins],
                      :select => options[:count] }
    if options[:conditions]
      count_options.update( { :conditions => options[:conditions],
                              :include => options[:include] } )
    end
    model.count(count_options)
  end

  # Affiche un message d'erreur si l'application a planté
  # dans une requête par exemple
  def error_message
    flash.now[:warning] = "Une erreur est survenue, veuillez nous contacter"
  end


private
  # scope imposé sur toutes les vues, 
  # pour limiter ce que peuvent voir nos clients
  def scope_beneficiaire
    beneficiaire = session[:beneficiaire]
    if beneficiaire
      client_id = beneficiaire.client_id
      contrat_ids = beneficiaire.contrat_ids 

      # damn fast with_scope (MLO ;))
      Binaire.set_scope(contrat_ids)
      Client.set_scope(client_id)
      Contribution.set_scope(contrat_ids)
      Demande.set_scope(client_id)
      Document.set_scope(client_id) 
      Logiciel.set_scope(contrat_ids)
      Paquet.set_scope(contrat_ids)
      Socle.set_scope(client_id)
      #Piecejointe.set_scope(client_id) #only for files
    end
    yield
  rescue Exception => e
    flash[:warn] = 'Une erreur est survenue. Notre service a été prévenue ' + 
      'et dispose des informations nécessaire pour corriger.<br />' +
      'N\'hésitez pas à nous contacter si le problème persiste.'
    Notifier::deliver_error_message(e,
                                    clean_backtrace(e),
                                    session.instance_variable_get("@data"),
                                    params,
                                    request.env)
    redirect_to :action => 'list', :controller => 'bienvenue'
  end

  # met le scope client en session
  # ca permet de ne pas recharger les ids contrats 
  # à chaque fois
  # call it like this : scope_client(params['filters']['client_id'])
  def scope_client(value)
    if value == '' 
      session[:contrat_ids] = nil 
    else
      conditions = { :client_id => value.to_i }
      options = { :select => 'id', :conditions => conditions }
      session[:contrat_ids] = Contrat.find(:all, options).collect{|c| c.id}
    end
  end



end
