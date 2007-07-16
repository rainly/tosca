#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ContributionsController < ApplicationController
  helper :filters, :demandes, :paquets, :binaires, :export, :urlreversements, :logiciels
  skip_before_filter :login_required
  before_filter :login_required, :except => [:index,:select,:show]

  # auto completion in 2 lines, yeah !
  auto_complete_for :logiciel, :nom

  def index
    unless params[:id]
      flash[:notice] = flash[:notice]
      return redirect_to(:action => 'select')
    end
    options = { :order => "created_on DESC" }
    unless params[:id] == 'all'
      @logiciel = Logiciel.find(params[:id])
      options[:conditions] = ['contributions.logiciel_id = ?', @logiciel.id]
    end
    @contribution_pages, @contributions = paginate :contributions, options
  end

  # TODO : c'est pas très rails tout ça (mais c'est moins lent)
  def select
    options = { :conditions =>
      'logiciels.id IN (SELECT DISTINCT logiciel_id FROM contributions)' }
    @logiciels = Logiciel.find(:all, options)
  end

  def admin
    conditions = []
    options = { :per_page => 10, :order => 'contributions.updated_on DESC',
      :include => [:logiciel,:etatreversement,:demandes] }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    conditions = Filters.build_conditions(params, [
       ['logiciel', 'nom', 'logiciels.nom', :like ],
       ['contribution', 'description', 'contributions.nom', :like ],
       ['filters', 'etatreversement_id', 'contributions.etatreversement_id', :equal ],
       ['filters', 'ingenieur_id', 'contributions.ingenieur_id', :equal ]
     ])
    flash[:conditions] = options[:conditions] = conditions

    @contribution_pages, @contributions = paginate :contributions, options
    # panel on the left side
    if request.xhr?
      render :partial => 'contributions_admin', :layout => false
    else
      _panel
      @partial_for_summary = 'contributions_info'
    end
  end

  def new
    @contribution = Contribution.new
    @urlreversement = Urlreversement.new
    # pour préciser le type dès la création
    @contribution.logiciel_id = params[:id]
    @contribution.ingenieur = @ingenieur
    _form
  end

  def create
    @contribution = Contribution.new(params[:contribution])
    if @contribution.save
      flash[:notice] = 'La contribution suivante a bien été créee : ' +
        '</br><i>'+@contribution.description+'</i>'
      _update(@contribution)
      flash[:notice] << '</br>L\'url a également été enregistrée.'
      redirect_to :action => 'show', :id => @contribution
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
    if @contribution.update_attributes(params[:contribution])
      flash[:notice] = 'La contribution suivante a bien été mise à jour ' +
        ': </br><i>'+@contribution.description+'</i>'
      _update(@contribution)
      redirect_to :action => 'show', :id => @contribution
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Contribution.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def ajax_paquets
    return render_text('') unless request.xml_http_request? and params[:id]

    # la magie de rails est cassé pour la 1.2.2, en mode production
    # donc je dois le faire manuellement
    # TODO : vérifier pour les versions > 1.2.2 en _production_ (!)
    clogiciel = [ 'paquets.logiciel_id = ?', params[:id].to_i ]
    options = Paquet::OPTIONS.dup
    options[:conditions] = clogiciel
    @paquets = Paquet.find(:all, options)
    options = Binaire::OPTIONS
    options[:conditions] = clogiciel
    @binaires = Binaire.find(:all, options)

    render :partial => 'liste_paquets', :layout => false
  end

private
  def _form
    @logiciels = Logiciel.find_select
    @paquets = @contribution.paquets || []
    @binaires = @contribution.binaires || []
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @typecontributions = Typecontribution.find_select
  end

  def _panel
    @etatreversements = Etatreversement.find_select
    @ingenieurs = Ingenieur.find_select(Identifiant::SELECT_OPTIONS)
    @logiciels = Logiciel.find_select
    # count
    clogiciels = { :select => 'contributions.logiciel_id', :distinct => true }
    @count = {:contributions => Contribution.count,
      :logiciels => Contribution.count(clogiciels) }
  end

  def _update(contribution)
    urlreversement = params[:urlreversement]
    if urlreversement != ''
      urlreverment[:contribution_id] = contribution.id
      Urlreversement.create(urlreversement)
    end
    contribution.reverse_le = nil if params[:contribution][:reverse] == '0'
    contribution.cloture_le = nil if params[:contribution][:clos] == '0'
    contribution.save
  end
end

