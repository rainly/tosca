class SoclesController < ApplicationController
  helper :clients,:binaires,:machines,:paquets

  def index
    @socle_pages, @socles = paginate :socles, :per_page => 250,
    :include => [:machine], :order=> 'socles.name'
  end

  def show
    @socle = Socle.find(params[:id], :include => [:machine])
    options = { :order => 'binaires.name,paquets.version',
      :include => [:paquet] }
    @binaires = Binaire.find_all_by_socle_id(@socle.id, options)
  end

  def new
    @socle = Socle.new
    _form
  end

  def create
    @socle = Socle.new(params[:socle])
    if @socle.save
      @socle.save
      flash[:notice] = _('A System was successfully created.')
      redirect_to socles_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @socle = Socle.find(params[:id])
    _form
  end

  def update
    @socle = Socle.find(params[:id])
    if @socle.update_attributes(params[:socle])
      flash[:notice] = _('A System was successfully updated.')
      redirect_to socles_path
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Socle.find(params[:id]).destroy
    redirect_to socles_path
  end

  private
  def _form
    @machines = Machine.find :all
    @clients = Client.find_select
  end

end
