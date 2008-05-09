#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class UrllogicielsController < ApplicationController
  helper :logiciels

  def index
    @urllogiciel_pages, @urllogiciels = paginate :urllogiciels,
     :per_page => 10, :include => [:logiciel,:typeurl],
     :order => 'urllogiciels.logiciel_id'
  end

  def show
    @urllogiciel = Urllogiciel.find(params[:id])
  end

  def new
    @urllogiciel = Urllogiciel.new
    @urllogiciel.logiciel_id = params[:logiciel_id]
    _form
  end

  def create
    @urllogiciel = Urllogiciel.new(params[:urllogiciel])
    if @urllogiciel.save
      flash[:notice] = _('The url of "%s" has been created successfully.') %
        @urllogiciel.valeur
      redirect_to logiciel_path(@urllogiciel.logiciel)
    else
      _form and render :action => 'new'
    end
  end

  def edit
    @urllogiciel = Urllogiciel.find(params[:id])
    _form
  end

  def update
    @urllogiciel = Urllogiciel.find(params[:id])
    if @urllogiciel.update_attributes(params[:urllogiciel])
      flash[:notice] = _("The Url has bean updated successfully.")
      redirect_to logiciel_path(@urllogiciel.logiciel)
    else
      _form and render :action => 'edit'
    end
  end

  def destroy
    url = Urllogiciel.find(params[:id])
    return_url = logiciel_path(url.logiciel)
    url.destroy
    redirect_to return_url
  end

private
  def _form
    @typeurls = Typeurl.find_select
    @logiciels = Logiciel.find_select
  end
end
