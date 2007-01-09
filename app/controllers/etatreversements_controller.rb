class EtatreversementsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @etatreversement_pages, @etatreversements = paginate :etatreversements, :per_page => 10
  end

  def show
    @etatreversement = Etatreversement.find(params[:id])
  end

  def new
    @etatreversement = Etatreversement.new
  end

  def create
    @etatreversement = Etatreversement.new(params[:etatreversement])
    if @etatreversement.save
      flash[:notice] = 'Etatreversement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @etatreversement = Etatreversement.find(params[:id])
  end

  def update
    @etatreversement = Etatreversement.find(params[:id])
    if @etatreversement.update_attributes(params[:etatreversement])
      flash[:notice] = 'Etatreversement was successfully updated.'
      redirect_to :action => 'show', :id => @etatreversement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Etatreversement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
