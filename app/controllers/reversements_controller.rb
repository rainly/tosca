#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class ReversementsController < ApplicationController

  helper :correctifs, :paquets, :demandes, :interactions

  before_filter :verifie, 
  :only => [ :show, :edit, :update, :destroy ]

  def verifie
    super(Reversement)
  end


  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @reversement_pages, @reversements = paginate :reversements, :per_page => 
      10, :include => [:etatreversement]
  end

  def show
    @reversement = Reversement.find(params[:id])
  end

  def new
    @reversement = Reversement.new
    _form
  end

  def create
    @reversement = Reversement.new(params[:reversement])
    if @reversement.save
      flash[:notice] = 'Reversement was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @reversement = Reversement.find(params[:id])
    _form
  end

  def update
    @reversement = Reversement.find(params[:id])
    if @reversement.update_attributes(params[:reversement])
      flash[:notice] = 'Reversement was successfully updated.'
      redirect_to :action => 'show', :id => @reversement
    else
      render :action => 'edit'
    end
  end

  def destroy
    Reversement.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private
  # TODO : cette fonction devrait �tre appel�ee dans le 
  # formulaire des interactions. Pour l'instant c'est un copier coller
  def _form
    @correctifs = Correctif.find_all
    @interactions = Interaction.find_all
    @etatreversements = Etatreversement.find_all
  end

end
