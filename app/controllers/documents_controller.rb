#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class DocumentsController < ApplicationController
  def index
    select
    render :action => 'select'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :select }

  def list
    @typedocument = Typedocument.find(params[:id])
    @document_pages, @documents = paginate :documents, :per_page => 10,
      :order => "created_on DESC", :conditions => ["typedocument_id = ?", @typedocument.id]
  end

  def select
    @typedocuments = Typedocument.find_all
    if @beneficiaire
      @typedocuments.delete_if { |t| 
        Document.count(:conditions => "documents.typedocument_id = #{t.id}") == 0
      }
    end
  end

  def show
    @document = Document.find(params[:id])
  end

  def new
    @document = Document.new
    @document.typedocument_id = params[:id]
    _form
  end

  def create
    @document = Document.new(params[:document])
    @document.identifiant = @session[:user]
    _form
    if @document.save
      flash[:notice] = 'Votre document a �t� correctement cr��.'
      redirect_to :action => 'select'
    else
      render :action => 'new'
    end
  end

  def edit
    @document = Document.find(params[:id])
    _form
  end

  def update
    @document = Document.find(params[:id])
    if @document.update_attributes(params[:document])
      flash[:notice] = 'Votre document a �t� correctement mis � jour.'
      redirect_to :action => 'show', :id => @document
    else
      render :action => 'edit'
    end
  end

  def destroy
    Document.find(params[:id]).destroy
    redirect_to :action => 'select'
  end

  private
  def scope_beneficiaire
    if @beneficiaire
      conditions = [ "documents.client_id = ?", @beneficiaire.client_id ]
      Document.with_scope({ :find => { 
                               :conditions => conditions
                          }
                        }) { yield }
    else
      yield
    end
  end

  def _form
    @clients = Client.find_all
    @typedocuments = Typedocument.find_all
    @identifiants = Identifiant.find_all
  end
end
