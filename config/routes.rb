#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # RESTful routes
  map.resources :accounts, 
    :controller => 'account',
    :member => { :modify => :any, :devenir => :post }, 
    :collection => { :logout => :post, :login => :any },
    :new => { :signup => :any, :multiple_signup => :any }
  map.resources :appels
  map.resources :arches
  map.resources :beneficiaires
  map.resources :bienvenue,
    :collection => { :index => :get, :admin => :get, :plan => :get, 
                     :selenium => :get, :about => :get }
  map.resources :binaires
  map.resources :clients
  map.resources :competences
  map.resources :contrats
  map.resources :contributions, 
    :collection => { :admin => :any, :select => :get },
    :member => { :list => :get }
  map.resources :demandes, 
    :member => { :comment => :any }
  map.resources :documents, 
    :collection => { :select => :get },
    :member => { :list => :get, :destroy => :delete }
  map.resources :export,
    :collection => { :contributions => :get, :appels => :get }
  map.resources :groupes
  map.resources :ingenieurs
  map.resources :logiciels
  map.resources :machines
  map.resources :paquets
  map.resources :permissions
  map.resources :reporting,
    :collection => { :comex => :get, :general => :get, :comex_resultat => :get, :configuration=> :get }
  map.resources :roles
  map.resources :socles
  map.resources :urllogiciels
 
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "bienvenue"

  # routing files to prevent download from public access
  options = { :controller => 'files', :action => 'download', :filename => /\w+(.\w+)*/ }
  map.files 'piecejointe/file/:id/:filename', options.update(:file_type => 'piecejointe')
  map.files 'contribution/patch/:id/:filename', options.update(:file_type => 'contribution')
  map.files 'document/fichier/:id/:filename', options.update(:file_type => 'document')
  map.files 'binaire/archive/:id/:filename', options.update(:file_type => 'binaire')

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

end
