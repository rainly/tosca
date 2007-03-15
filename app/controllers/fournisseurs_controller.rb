#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class FournisseursController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]


  def list
    @fournisseur_pages, @fournisseurs = paginate :fournisseurs, :per_page => 10
  end

  def show
    @fournisseur = Fournisseur.find(params[:id])
  end

  def new
    @fournisseur = Fournisseur.new
  end

  def create
    @fournisseur = Fournisseur.new(params[:fournisseur])
    if @fournisseur.save
      flash[:notice] = 'Fournisseur was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @fournisseur = Fournisseur.find(params[:id])
  end

  def update
    @fournisseur = Fournisseur.find(params[:id])
    if @fournisseur.update_attributes(params[:fournisseur])
      flash[:notice] = 'Fournisseur was successfully updated.'
      redirect_to :action => 'show', :id => @fournisseur
    else
      render :action => 'edit'
    end
  end

  def destroy
    Fournisseur.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  private
  def verifie
    super(Fournisseur)
  end
end
