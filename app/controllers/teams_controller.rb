class TeamsController < ApplicationController

  def index
    @teams = Team.find(:all)
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
    @users = User.find(:all)
  end

  def edit
    _form
    @team = Team.find(params[:id])
  end

  def create
    _form
    @team = Team.new(params[:team])
    if @team.save
      flash[:notice] = _('Team %s was successfully created.') % @team.name
      redirect_to(@team)
    else
      render :action => "new"
    end
  end

  def update
    _form
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      flash[:notice] = _('Team %s was successfully updated.') % @team.name
      redirect_to(@team)
    else
      render :action => "edit"
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to(teams_url)
  end
  
private
  def _form
    @users = User.find_select
  end
end
