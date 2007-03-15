#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class UrlreversementsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  before_filter :verifie, :only => [ :show, :edit, :update, :destroy ]

  def list
    @urlreversement_pages, @urlreversements = paginate :urlreversements, 
    :per_page => 10
  end

  def show
    @urlreversement = Urlreversement.find(params[:id])
  end

  def new
    @urlreversement = Urlreversement.new
    _form
  end

  def create
    @urlreversement = Urlreversement.new(params[:urlreversement])
    if @urlreversement.save
      flash[:notice] = 'Urlreversement was successfully created.'
      redirect_to :action => 'list'
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urlreversement = Urlreversement.find(params[:id])
    _form
  end

  def update
    @urlreversement = Urlreversement.find(params[:id])
    if @urlreversement.update_attributes(params[:urlreversement])
      flash[:notice] = 'Urlreversement was successfully updated.'
      redirect_to :controller => 'contributions', 
                   :action => 'show', :id => @urlreversement.contribution_id
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    Urlreversement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

private
  def _form
    @contributions = Contribution.find(:all)
    if params[:contribution_id]
      @urlreversement.contribution_id = params[:contribution_id].to_i 
    end
  end

  def verifie
    super(Urlreversement)
  end
end
