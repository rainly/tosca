#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class BienvenueController < ApplicationController

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
  
  # Includes somme helpers
  helper :demandes, :account

  # Default page, redirect if necessary
  def index
    _my_list
    @typedocuments = Typedocument.find(:all)
    # this line will be deleted when index is ready
    render :action => 'list'
  end
 
  # Welcome page
  # DEPRECATED : use index
  def list
    _my_list
  end

  # New welcome page, current development
  def test
  end

  # Display all method that user can access
  def plan
    _plan
  end

  # Functionnal testing
  def selenium
    _plan
    render :layout => false
  end

  # About this software
  def about
  end

private

  # Return all methods sorted by class name
  def _plan
    classes = Hash.new;
    require 'find'
    Find.find(File.join(RAILS_ROOT, 'app/controllers'))  { |name|
        require_dependency(name) if /_controller\.rb$/ =~ name
    }
    # définition de @classes[] : listes des controllers de l'application
    ObjectSpace.subclasses_of(::ActionController::Base).each do |obj|
      classes["#{obj.controller_name}"] = obj
    end
    @classes = classes.sort {|a,b| a[0]<=>b[0]}
  end

  # Pick some demands
  # Used to be shown in the welcome page
  def _my_list
    conditions = Demande::EN_COURS
    @demandes = Demande.find(:all, 
       :include => [:statut, :typedemande, :severite], 
       :limit => 5, :order => "updated_on DESC ",
       :conditions => conditions)
  end 

end

