#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
require_dependency 'filters'

class SoftwaresController < ApplicationController
  helper  :contracts, :contributions, :groups, :hyperlinks,
    :issues, :licenses, :skills, :versions

  cache_sweeper :software_sweeper, :only => [:update, :destroy]

  # ajaxified list
  def index
    scope = nil
    @title = _('List of software')
    if @session_user and @session_user.recipient? && params['active'] != '0'
      scope = :supported
      @title = _('List of your supported software')
    end

    options = { :order => 'softwares.name', :per_page => 15, :include =>
      [:picture,:skills], :page => params[:page] }
    conditions = []

    if params.has_key? :filters
      session[:software_filters] = Filters::Softwares.new(params[:filters])
    end
    conditions = nil
    software_filters = session[:software_filters]
    if software_filters
      # we do not want an include since it's only for filtering.
      unless software_filters['contract_id'].blank?
        options[:joins] =
          'INNER JOIN versions ON versions.software_id=softwares.id ' +
          'INNER JOIN contracts_versions cv ON cv.version_id=versions.id'
      end

      # Specification of a filter f :
      #   [ field, database field, operation ]
      # All the fields must be coherent with lib/filters.rb related Struct.
      conditions = Filters.build_conditions(software_filters, [
        [:software, 'softwares.name', :like ],
        [:description, 'softwares.description', :like ],
        [:group, 'softwares.cached_tag_list', :like ],
        [:contract_id, ' cv.contract_id', :in ]
      ])
      @filters = software_filters
    end
    flash[:conditions] = options[:conditions] = conditions

    # optional scope, for customers
    begin
      Software.set_index_scope(@session_user) if scope
      @softwares = Software.paginate options
    ensure
      Software.remove_scope if scope
    end

    # panel on the left side. cookies is here for a correct 'back' button
    if request.xhr?
      render :layout => false
    else
      _panel
      @partial_panel = 'index_panel'
    end
  end

  def show
    @software = Software.find(params[:id])
    conditions = { :conditions => ['issues.software_id=?', @software.id] }
  end

  def card
    @software = Software.find(params[:id])
  end

  def new
    @software = Software.new
    _form
  end

  def create
    @software = Software.new(params[:software])
    if @software.save and add_logo
      flash[:notice] = _('The software %s has been created succesfully.') % @software.name
      redirect_to software_path(@software)
    else
      add_image_errors
      _form and render :action => 'new'
    end
  end

  def edit
    @software = Software.find(params[:id])
    _form
  end

  def update
    @software = Software.find(params[:id])
    if @software.update_attributes(params[:software]) and add_logo
      flash[:notice] = _('The software %s has been updated successfully.') % @software.name
      redirect_to software_path(@software)
    else
      add_image_errors
      _form and render :action => 'edit'
    end
  end

  def destroy
    @software = Software.find(params[:id])
    @software.destroy
    flash[:notice] = _('The software %s has been successfully deleted.') % @software.name
    redirect_to softwares_path
  end

  def ajax_update_tags
    return unless request.xhr? && params.has_key?(:software)
    software = params[:software]
    @software = Software.new(software)
    render :partial => 'tags', :layout => false
  end

private
  def _form
    @skills = Skill.find_select
    @groups = Software.tag_counts.collect{|t| [t.id, t.name]}
    @licenses = License.find_select
  end

  def _panel
    @contracts = Contract.find_select(Contract::OPTIONS) if @session_user and @session_user.engineer?
    @technologies = Skill.find_select
    @groups = Software.tag_counts.collect{|t| [t.name, t.name]}
  end

  def add_logo
    image = params[:picture]
    if image.nil? || image[:image].blank?
      true
    else
      image[:description] = @software.name
      @software.picture = Picture.new(image)
      @software.picture.save and @software.save
    end
  end

  # because :save resets @software.errors
  def add_image_errors
    unless @software.picture.nil?
      @software.picture.errors.each do |attr, msg|
        @software.errors.add :image, msg
      end
    end
  end


end
