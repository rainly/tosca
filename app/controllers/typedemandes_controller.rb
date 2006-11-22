class TypedemandesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @typedemande_pages, @typedemandes = paginate :typedemandes, :per_page => 10
  end

  def show
    @typedemande = Typedemande.find(params[:id])
  end

  def new
    @typedemande = Typedemande.new
  end

  def create
    @typedemande = Typedemande.new(params[:typedemande])
    if @typedemande.save
      flash[:notice] = 'Typedemande was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @typedemande = Typedemande.find(params[:id])
  end

  def update
    @typedemande = Typedemande.find(params[:id])
    if @typedemande.update_attributes(params[:typedemande])
      flash[:notice] = 'Typedemande was successfully updated.'
      redirect_to :action => 'show', :id => @typedemande
    else
      render :action => 'edit'
    end
  end

  def destroy
    Typedemande.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
