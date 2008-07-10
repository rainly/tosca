class PaquetsController < ApplicationController
  helper :filters, :logiciels, :binaires, :distributeurs,
    :mainteneurs

  # auto completion in 2 lines, yeah !
  auto_complete_for :version, :name

  # TODO : filtres du panel à gauche
  # TODO : faire une interface à base de filtres ?
  # ou  pas d'interfaces du tout.
  def index
    options = { :per_page => 15, :order =>
      'versions.logiciel_id, versions.version, versions.release',
      :include => [:distributeur,:mainteneur,:logiciel] }

    # Specification of a filter f :
    # [ namespace, field, database field, operation ]
    params_version = params['version']
    conditions = Filters.build_conditions(params_version, [
       ['name', 'versions.name', :like ]
     ]) unless params_version.blank?
    flash[:conditions] = options[:conditions] = conditions

    @version_pages, @versions = paginate :versions, options

    # panel on the left side
    if request.xhr?
      render :partial => 'versions_list', :layout => false
    else
      _panel
      @partial_for_summary = 'versions_info'
    end
  end

  def show
    include =  [ { :logiciel => :groupe }, :distributeur,
                 { :contract => :client }, :mainteneur, :conteneur ]
    version_id = params[:id]
    @version = Paquet.find(version_id, :include => include)
    cond = [ 'binaires.version_id = ? ', version_id ]
    options = { :conditions => cond, :include => [:version,:socle,:arch] }
    @binaires = Binaire.find(:all, options)
    @changelogs = @version.changelogs
  end

  def new
    @version = Paquet.new
    _form
    @version.mainteneur = Mainteneur.find_by_name('Linagora')
    @version.distributeur = Distributeur.find_by_name('(none)')
    @version.logiciel_id = params[:logiciel_id]
    @version.name = params[:referent]
    @version.release = 'lng1'
    @version.active = true;
  end

  def create
    @version = Paquet.new(params[:version])
    if @version.save
      flash[:notice] = _('The package %s has been created.') % @version.name
      redirect_to logiciel_path(@version.logiciel)
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @version = Paquet.find(params[:id])
    _form
  end

  def update
    @version = Paquet.find(params[:id])
    if @version.update_attributes(params[:version])
      flash[:notice] = _('The package %s has been updated.') % @version.name
      redirect_to version_path(@version)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Paquet.find(params[:id]).destroy
    redirect_back
  end

  private
  def _form
    @logiciels = Logiciel.find_select
    @groupes = Groupe.find_select
    @socles = Socle.find_select
    @conteneurs = Conteneur.find_select
    @distributeurs = Distributeur.find_select
    @mainteneurs = Mainteneur.find_select
    @contracts = Contract.find_select(Contract::OPTIONS)
  end

  def _panel
    @count = {}
    @clients = Client.find_select(:conditions => 'clients.inactive = 0')
    @count[:versions] = Paquet.count
    @count[:binaires] = Binaire.count(:include => :version)
  end

end
