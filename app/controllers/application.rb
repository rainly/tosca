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

  before_filter :set_filters
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
    set_sessions unless @session[:filtres]
    @ingenieur = @session[:ingenieur]
    @beneficiaire = @session[:beneficiaire]
    # TODO : encore n�cessaire ? Non !!
    @user_group = (@ingenieur ? 'ing�nieur' : 'b�n�ficiaire')
  end

  protected
  
  # variable utilisateurs; n�cessite @session[:user]
  # penser � mettre � jour les pages statiques 404 et 500 en cas de modification
  def set_sessions
    return unless @session[:user]
    @session[:filtres] = Hash.new
    @session[:beneficiaire] = @session[:user].beneficiaire
    @session[:ingenieur] = @session[:user].ingenieur
    @session[:logo_lstm] = render_to_string :inline => 
      "<%=image_tag('logo_lstm.gif', :alt => 'Accueil', :title => 'Accueil' )%>"
    @session[:logo_08000] = render_to_string :inline => 
      "<%=image_tag('logo_08000.gif', :alt => '08000 LINUX', :title => '08000 LINUX' )%>"
    @session[:nav_links] = render_to_string :inline => "
        <% nav_links = [ 
          (link_to 'Accueil',:controller => 'bienvenue', :action => 'list'),
          (link_to 'D�connexion',:controller => 'account', :action => 'logout'), 
          (link_to_my_account),
          (link_to 'Plan',:controller => 'bienvenue', :action => 'plan'),
          (link_to 'Utilisateurs', :controller => 'account', :action => 'list')
        ] %>
        <%= nav_links.compact.join('&nbsp;|&nbsp;') if @session[:user] %>"
    @session[:cut_links] = render_to_string :inline => "
        <% cut_links = [ 
          (link_to 'Demandes',:controller => 'demandes', :action => 'list') " +
          (@session[:user].authorized?('demandes/list') ? 
              "+ '&nbsp;' + (text_field 'numero', '', 'size' => 3)," : ',' ) + 
              "(link_to 'Logiciels',:controller => 'logiciels', :action => 'list'),
          (link_to 'Projets',:controller => 'projets', :action => 'list'),
          (link_to 'T�ches',:controller => 'taches', :action => 'list'),
          (link_to 'Correctifs',:controller => 'correctifs', :action => 'list'),
          (link_to 'R�pertoire',:controller => 'documents', :action => 'select'), 
          (link_to_my_client), 
          (link_to 'Clients',:controller => 'clients', :action => 'list')
        ] %>
        <%= start_form_tag :controller => 'demandes', :action => 'list' %>
        <%= cut_links.compact.join('&nbsp;|&nbsp;') %>
        <%= end_form_tag %>"
  end

  # encodage
  def set_charset
    @headers['Content-Type'] = 'text/html; charset=ISO-8859-1'
  end

  # d�fini les filtres de tri
  # TODO : VA MLO
  def set_filters
    @session[:filtres] ||= {}
    @session[:filtres][:liste_globale] = case params['filter']
      when 'true' : true
      when 'false' : false
      else nil
    end
    # les filtres sont nomm�s "filtres[nom_du_parametre]"
    if params['filtres']
      params['filtres'].each{|p|
        set_filter(p[0])
      }
    end
  end

  # positionne un filtre de tri
  # TODO : faire une regexp : to_i si filtre se termine par "_id"
  # mais �a n'a pas l'air necessaire
  # @session[:filtres][filtre].to_i if options[:to_i]
  # � v�rifier en d�tail
  def set_filter(filtre, options = {})
    if params['filtres'][filtre]
      if params['filtres'][filtre] != ''
        value = params['filtres'][filtre]
        value = value.to_i if filtre =~ /(_id)$/
        @session[:filtres][filtre] = value
      else
        @session[:filtres][filtre] = nil      
      end
    end
  end

  # scope
  # TODO : c'est pas DRY, une sous partie a �t� recopi� dans reporting
  def scope_beneficiaire

    # on applique les filtre sur les listes uniquement
    # le scope client est tout de m�me appliqu� partout si client
    filtres = ( self.action_name == 'list' ? @session[:filtres] : {} )

    # scope impos�s si l'utilisateur est beneficiaire
    if @beneficiaire
      client_id = @beneficiaire.client_id
      contrat_ids = @beneficiaire.contrat_ids || [ 0 ]
    else
      client_id = filtres['client_id'] if filtres['client_id']
      contrat_ids = filtres['contrat_ids'] if filtres['contrat_ids']
    end

    # on construit les conditions pour les demandes et les logiciels
    cdemande_severite = ['demandes.severite_id = ? ', filtres['severite_id'] ] if filtres['severite_id'] 
    cdemande_motcle = ['(demandes.resume LIKE ? OR demandes.description LIKE ?) ', 
                       "%#{filtres['motcle']}%", "%#{filtres['motcle']}%"] if filtres['motcle']
    cdemande_ingenieur = ['demandes.ingenieur_id = ? ', filtres['ingenieur_id'] ] if filtres['ingenieur_id']
    cdemande_beneficiaire = ['demandes.beneficiaire_id = ? ', filtres['beneficiaire_id'] ] if filtres['beneficiaire_id']
    cdemande_type = ['demandes.typedemande_id = ? ', filtres['typedemande_id'] ] if filtres['typedemande_id']
    cdemande_statut = ['demandes.statut_id = ? ', filtres['statut_id'] ] if filtres['statut_id']
    clogiciel = [ 'logiciels.id = ? ', filtres['logiciel_id'] ] if filtres['logiciel_id'] 
    if client_id
      cclient = ['clients.id = ? ', client_id ] 
      cbeneficiaire_client = ['beneficiaires.client_id = ? ', client_id ] 
      cdocument_client = ['documents.client_id = ? ', client_id ]
    end
    if contrat_ids
      cpaquet_contrat = ['paquets.contrat_id IN (?) ', contrat_ids ]
    end

    # on construit les scopes
    sdemandes = compute_scope([:beneficiaire,:logiciel],
                              cbeneficiaire_client, 
                              cdemande_severite, 
                              cdemande_motcle, 
                              cdemande_ingenieur, 
                              cdemande_beneficiaire, 
                              cdemande_type,
                              clogiciel, 
                              cdemande_statut)
    slogiciels = compute_scope([:paquets], clogiciel, cpaquet_contrat)
    sclients = compute_scope(nil, cclient)
    spaquets = compute_scope(nil, cpaquet_contrat)
    sbinaires = compute_scope([:paquets], cpaquet_contrat)
    ssocles = compute_scope([:clients], cclient)
    sbeneficiaire = compute_scope(nil, cbeneficiaire_client)
    sdocuments = compute_scope(nil, cdocument_client)
    scorrectifs = compute_scope([:paquets,:logiciel], clogiciel, cpaquet_contrat)

    # with_scope
    Beneficiaire.with_scope(sbeneficiaire) {
    Binaire.with_scope(sbinaires) {
    Client.with_scope(sclients) {
    Correctif.with_scope(scorrectifs) {
    Demande.with_scope(sdemandes) {
    Document.with_scope(sdocuments) {
    Logiciel.with_scope(slogiciels) {
    Paquet.with_scope(spaquets) {
    Socle.with_scope(ssocles) { 
    yield }}}}}}}}}

  end

  # surcharge des requetes find
  # TODO :VA MLO
  def compute_scope(include = nil, *args)
    args.compact!
    return {} if args.empty?

    # si conditions est une condition (et non pas un tableau de conditions)
    # on vire les nil
    
    query, params = [], []
    args.each do |condition| 
      query.push condition[0] 
      params.concat condition[1..-1]
    end

      
    #query.compact!
    computed_conditions = [ query.join(' AND ') ] + params
    computed_conditions.compact!
    return {} if computed_conditions[0] == ''
    return {:find => {:conditions => computed_conditions, :include => include}} 
  end

  # verifie :
  # - s'il il y a un id en param�tre (sinon :  retour � la liste)
  # - si un ActiveRecord ayant cet id existe (sinon : erreur > rescue > retour � la liste)
  # options
  # :controller en cas de redirection (bienvenue)
  # :action en cas de redirection (list)
  # TODO : trop de copier-coller 
  # NOTODO : "options[:controller] = controller_name" par d�faut
  #       c'est id�al, mais les clients n'ont pas les droits sur tous les */list
  #       on tombe alors sur un acces/refuse, dommage
  def verifie(ar, options = {:controller => 'bienvenue', :action => 'list'})
    if !params[:id]
      flash[:warn] = 'Veuillez pr�ciser l\'identifiant de la demande � consulter.'
      redirect_to(options) and return false
    end
    scope_beneficiaire {
      object = ar.find(params[:id], :select => 'id') 
      if object = nil
        flash[:warn] = "Aucun(e) #{ar.to_s} ne correspond � l'identifiant #{params[:id]}."
        redirect_to(options) and return false
      end
    }
    true
  rescue  ActiveRecord::RecordNotFound
    flash[:warn] = "Aucun(e) #{ar.to_s} ne correspond � l'identifiant #{params[:id]}."
    redirect_to(options) and return false
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



