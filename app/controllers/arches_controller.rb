#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class ArchesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  def list
    @arch_pages, @arches = paginate :arches, :per_page => 10
  end

  def show
    @arch = Arch.find(params[:id])
  end

  def new
    @arch = Arch.new
  end

  def create
    @arch = Arch.new(params[:arch])
    if @arch.save
      flash[:notice] = 'Arch was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @arch = Arch.find(params[:id])
  end

  def update
    @arch = Arch.find(params[:id])
    if @arch.update_attributes(params[:arch])
      flash[:notice] = 'Arch was successfully updated.'
      redirect_to :action => 'show', :id => @arch
    else
      render :action => 'edit'
    end
  end

  def destroy
    Arch.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
