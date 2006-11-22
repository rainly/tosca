class BienvenueController < ApplicationController

  helper :demandes, :account

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  #    @user = @session[:user] # cf identifiants


  def list
    conditions = [ "statut_id NOT IN (?,?)", 7, 8 ]
    if @ingenieur
      @demandes = Demande.find_all_by_ingenieur_id(@ingenieur.id,
                                                   :limit => 5,
                                                   :conditions => conditions,
                                                   :order => "updated_on DESC")
      @clients = @ingenieur.contrats.collect{|c| c.client.nom}
    elsif @beneficiaire
      # Ce code a �t� copi� depuis le controller de demandes, dans scope_beneficiaire
      # C'est mal, il faudra trouver une solution
      liste = @beneficiaire.client.beneficiaires.collect{|b| b.id}.join(',')
      conditions = [ "demandes.beneficiaire_id IN (#{liste})" ]
      Demande.with_scope({ :find => { :conditions => conditions } }) do
        @demandes = Demande.find(:all, :limit => 5, :order => "updated_on DESC ")
      end
      @client = @beneficiaire.client.nom
    else    
      flash[:warn] = "Vous n'�tes pas identifi� comme appartenant � un groupe.\
                        Veuillez nous contacter pour nous avertir de cet incident."
      @demandes = [] # renvoi un tableau vide
    end   

  end


  def plan
  end

end

