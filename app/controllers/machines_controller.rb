class MachinesController < ApplicationController
  helper :socles

  def index
    options = { :per_page => 250, :include => [:socle,:hote], :order =>
        'machines.hote_id, machines.acces' }
    @machine_pages, @machines = paginate :machines, options
  end

  def show
    @machine = Machine.find(params[:id])
  end

  def new
    @machine = Machine.new
    _form
  end

  def create
    @machine = Machine.new(params[:machine])
    if @machine.save
      flash[:notice] = _('Machine was successfully created.')
      redirect_to machines_path
    else
      _form
      render :action => 'new'
    end
  end

  def edit
    @machine = Machine.find(params[:id])
    _form
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update_attributes(params[:machine])
      flash[:notice] = _('Machine was successfully updated.')
      redirect_to machine_path(@machine)
    else
      _form
      render :action => 'edit'
    end
  end

  def destroy
    Machine.find(params[:id]).destroy
    redirect_to machines_path
  end

  private
  def _form
    @socles = Socle.find(:all, :select => 'socles.name, socles.id',
                         :order => 'socles.name')
    conditions = ['machines.virtuelle = ?', 0]
    @hotes = Machine.find(:all, :select => 'machines.acces, machines.id',
                          :conditions => conditions)
  end
end
