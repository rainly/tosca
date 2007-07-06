#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class RolesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @permissions = Permission.find(:all, :order => 'name', :include => [:roles])
    @roles = Role.find(:all)
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    _form
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = "Le rôle \"#{@role.nom}\" a bien été crée."
      redirect_to roles_url
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    _form
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = "Le rôle \"#{@role.nom}\" a bien été mis à jour."
      redirect_to roles_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to roles_url
  end

  private
  def _form
    @permissions = Permission.find(:all, :order => 'name')
  end
end
