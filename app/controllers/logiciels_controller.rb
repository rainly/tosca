#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class LogicielsController < ApplicationController
  helper :paquets, :demandes, :competences

  before_filter :verifie, :only => 
    [ :show, :edit, :update, :destroy ]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def verifie
    super(Logiciel)
  end

  def index
    list
    render :action => 'list'
  end

  def content_columns
     @content_columns ||= columns.reject { |c| c.primary || c.name =~ /(_id|_count|Description)$/ || c.name == inheritance_column }
  end

  # affiche la liste des logiciels avec filtres
  def list
    @filter = params[:filter]
    @search = params[:logiciel]
    if $orderway == nil || $orderway == " ASC"
	$orderway = " DESC"
    else
        $orderway = " ASC"
    end
    if @order != nil 
      @order += $orderway
    end

    conditions = nil
    if @search != nil
      conditions = [ " logiciels.nom LIKE ?", "%" + @search[0] + "%" ]
    end

    @groupes = Classification.find(:all).collect{|c| c.groupe}.uniq
    scope_filter do
      @logiciel_pages, @logiciels = paginate :logiciels, :per_page => 25,
      :order => 'logiciels.nom', :conditions => conditions 
    end
  end

  def rpmlist
    @logiciels = Logiciel.find(:all)
  end

  def show
    @logiciel = Logiciel.find(params[:id])
    if @beneficiaire
      @demandes = @beneficiaire.demandes.find_all_by_logiciel_id(params[:id])
    else
      @demandes = Demande.find_all_by_logiciel_id(params[:id])
    end
  end

  def new
    @logiciel = Logiciel.new
    @competences = Competence.find(:all, :order => "nom")
    @classifications = Classification.find_all
    @licenses = License.find_all
  end

  def create
    @logiciel = Logiciel.new(params[:logiciel])

    if @params[:competence_ids]
      @logiciel.competences = Competence.find(@params[:competence_ids]) 
    else
      @logiciel.competences = []
      @logiciel.errors.add_on_empty('competences') 
      render :action => 'edit'
      return 
    end

    if @logiciel.save
      flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été crée.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @logiciel = Logiciel.find(params[:id])
    @competences = Competence.find(:all, :order => "nom")
    @classifications = Classification.find(:all, :order => "client_id, bouquet_id, groupe_id")
    @licenses = License.find(:all, :order => "nom")
  end

  def update
    @logiciel = Logiciel.find(params[:id])
    @licenses = License.find_all
    @competences = Competence.find_all

    if @params[:competence_ids]
      @logiciel.competences = Competence.find(@params[:competence_ids]) 
    else
      @logiciel.competences = []
      @logiciel.errors.add_on_empty('competences') 
      render :action => 'edit'
      return 
    end

    if @logiciel.update_attributes(params[:logiciel])
      flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été mis à jour.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @logiciel = Logiciel.find(params[:id])
    @logiciel.destroy
    flash[:notice] = 'Le logiciel '+@logiciel.nom+' a bien été supprimé.'
    redirect_to :action => 'list'
  end

  private

end
