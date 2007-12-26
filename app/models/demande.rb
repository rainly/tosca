#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

class Demande < ActiveRecord::Base
  belongs_to :typedemande
  belongs_to :logiciel
  belongs_to :severite
  belongs_to :beneficiaire
  belongs_to :statut
  belongs_to :ingenieur
  belongs_to :contrat
  has_and_belongs_to_many :paquets
  # TODO : à voir si c'est inutile. avec le socle, on a dejà la plateforme
  has_and_belongs_to_many :binaires
  has_many :phonecalls
  belongs_to :contribution
  belongs_to :socle
  has_many :piecejointes, :through => :commentaires

  # Key pointers to the request history
  belongs_to :first_comment, :class_name => "Commentaire",
    :foreign_key => "first_comment_id"
  # /!\ It's the last _public_ comment /!\
  belongs_to :last_comment, :class_name => "Commentaire",
    :foreign_key => "last_comment_id"

  # Validation
  validates_presence_of :resume,
       :warn => _("You must indicate a summary for your request")
  validates_length_of :resume, :within => 5..70
  validates_presence_of :contrat
  attr_accessor :description
  validates_length_of :description, :minimum => 5
  validates_presence_of :description,
    :warn => _('You must indicate a description')

  validate do |record|
    if record.contrat.nil? or (record.contrat.client_id != record.beneficiaire.client_id)
      record.errors.add _('The client of this contract is not consistant with the client of this recipient.')
    end
    if record.beneficiaire.nil?
      record.errors.add _('You must indicate a valid recipient')
    end
    if record.statut_id == 0
      record.errors.add _('You must indicate a valid status')
    end
    if record.severite_id == 0
      record.errors.add _('You must indicate a valid severity')
    end
  end
  #versioning, qui s'occupe de la table demandes_versions
  # acts_as_versioned
  # has_many :commentaires, :order => "updated_on DESC", :dependent => :destroy
  after_save :update_first_comment
  after_create :create_first_comment
  has_many :commentaires, :order => "created_on ASC", :dependent => :destroy

  # used for ruport. See plugins for more information
  acts_as_reportable

  # self-explanatory
  TERMINEES = "demandes.statut_id IN (#{Statut::CLOSED.join(',')})"
  EN_COURS = "demandes.statut_id IN (#{Statut::OPENED.join(',')})"

  # WARNING : you cannot use this scope with the optimisation hidden
  # in the model of Demande. You must then use get_scope_without_include
  def self.set_scope(client_ids)
    scope = { :conditions => [ 'beneficiaires.client_id IN (?)', client_ids],
      :include => [:beneficiaire] }
    self.scoped_methods << { :find => scope, :count => scope }
  end

  # return the condition of the scope.
  # Used in controller demande for the speed n dirty hack finder
  # on list actions
  def self.get_scope_without_include(client_ids)
    { :find => { :conditions =>
        [ 'beneficiaires.client_id IN (?)', client_ids]} }
  end

  # DIRTY HACK : WARNING
  # We need this hack for avoiding 7 includes
  # TODO : find a better way
  def self.without_include_scope(ingenieur, beneficiaire)
    escope = {}
    if beneficiaire
      escope = Demande.get_scope_without_include([beneficiaire.client_id])
    end
    if ingenieur and not ingenieur.expert_ossa
      escope = Demande.get_scope_without_include(ingenieur.client_ids)
    end
    self.with_exclusive_scope(escope) { yield }
  end

  def to_param
    "#{id}-#{resume.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    "#{typedemande.name} (#{severite.name}) : #{resume}"
  end

  def name
    to_s
  end

  def find_last_comment_before(comment_id)
    options = { :order => 'created_on DESC', :conditions =>
      [ 'commentaires.prive <> 1 AND commentaires.id <> ?', comment_id ]}
    self.commentaires.find(:first, options)
  end

  def update_first_comment
    first_comment = self.first_comment
    if first_comment and first_comment.corps != self.description
      first_comment.update_attribute(:corps, self.description)
    end
  end

  def create_first_comment
    comment = Commentaire.new do |c|
      #We use id's because it's quicker
      c.corps = self.description
      c.ingenieur_id = self.ingenieur_id
      c.demande_id = self.id
      c.severite_id = self.severite_id
      c.statut_id = self.statut_id
      c.user_id = self.beneficiaire.user_id
    end
    if comment.save
      self.first_comment_id = comment.id
      self.save
    else
      self.destroy
      throw Exception.new('Erreur dans la sauvegarde du premier commentaire')
    end
  end

  # /!\ Dirty Hack Warning /!\
  # We use finder for overused view mainly (demandes/list)
  # It's about 40% faster with this crap (from 2.8 r/s to 4.0 r/s)
  # it's not enough, but a good start :)
  SELECT_LIST = 'demandes.*, severites.name as severites_name, ' +
    'logiciels.name as logiciels_name, clients.name as clients_name, ' +
    'typedemandes.name as typedemandes_name, statuts.name as statuts_name '
  JOINS_LIST = 'INNER JOIN severites ON severites.id=demandes.severite_id ' +
    'INNER JOIN beneficiaires ON beneficiaires.id=demandes.beneficiaire_id '+
    'INNER JOIN clients ON clients.id = beneficiaires.client_id '+
    'INNER JOIN typedemandes ON typedemandes.id = demandes.typedemande_id ' +
    'INNER JOIN statuts ON statuts.id = demandes.statut_id ' +
    'LEFT OUTER JOIN logiciels ON logiciels.id = demandes.logiciel_id '

  def updated_on_formatted
    d = @attributes['updated_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end

  def created_on_formatted
    d = @attributes['created_on']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} #{d[11,2]}:#{d[14,2]}"
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
      c.name =~ /(_id|_on|resume)$/ ||
      c.name == inheritance_column }
  end

  def client
    @client ||= ( beneficiaire ? beneficiaire.client : nil )
    @client
  end

  def respect_contournement(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).contournement)
  end

  def respect_correction(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).correction)
  end

  def affiche_temps_correction
    distance_of_time_in_french_words(self.temps_correction, self.contrat)
  end

  def temps_correction
    result = 0
#     corrigee = self.versions.find(:first, :conditions => 'statut_id IN (6,7)',
#                                   :order => 'updated_on ASC')
    corrigee = self.commentaires.find(:first, :conditions => 'statut_id IN (6,7)',
                                      :order => 'updated_on ASC')
    if corrigee and self.appellee()
      result = compute_temps_ecoule(corrigee.statut_id)
    end
    result
  end

  # Retourne le délais imparti pour corriger la demande
  # TODO : validation MLO
  # TODO : inaffichable dans la liste des demandes > améliorer le calcul de ce délais
  def delais_correction
    delais = paquets.compact.collect{ |p|
      p.correction(typedemande_id, severite_id) *
      p.contrat.interval_in_seconds
    }.min
  end

  def affiche_temps_contournement
    distance_of_time_in_french_words(self.temps_contournement, self.contrat)
  end

  def temps_contournement
    result = 0
#     contournee = self.versions.find(:first, :conditions => 'statut_id=5',
#                                     :order => 'updated_on ASC')
    contournee = self.commentaires.find(:first, :conditions => 'statut_id=5',
                                        :order => 'updated_on ASC')
    if contournee and self.appellee()
      result = compute_temps_ecoule(5)
    end
    result
  end

  def affiche_temps_rappel
    self.distance_of_time_in_french_words(self.temps_rappel, self.contrat)
  end

  def temps_rappel
    result = 0
#     if (self.versions.size > 2) and (first.statut_id == 1) and self.appellee()
    first_comment = self.first_comment
    if (first_comment and first_comment.statut_id == 1) and self.appellee()
      result = compute_diff(first_comment.updated_on, appellee().updated_on,
                            self.contrat)
    end
    result
  end

  def engagement(contrat_id)
    conditions = [" contrats_engagements.contrat_id = ? AND " +
      "engagements.severite_id = ? AND engagements.typedemande_id = ? ",
      contrat_id, severite_id, typedemande_id ]
    joins = " INNER JOIN contrats_engagements ON engagements.id = contrats_engagements.engagement_id"
    Engagement.find(:first, :conditions => conditions, :joins => joins)
  end

  #on ne calcule qu'une fois par instance
  def temps_ecoule
    @temps_passe ||= compute_temps_ecoule
    @temps_passe
  end

  #Oui ces 2 fonctions n'ont rien à faire dans un modèle.
  # Mais l'affichage dépend du modèle (du support client)
  # donc en fait si ^_^
  #
  # if the demande is over, then return the overrun time
  def affiche_temps_ecoule
    temps = temps_ecoule
    return "sans engagement" if temps == -1

    contrats = Contrat.find(:all)
    contrats.delete_if { |contrat|
      engagement= engagement(contrat.id)
      engagement == nil or engagement.correction < 0
    }
    # A demand may have several contracts.
    # I keep the more critical correction time
    critical_contract = contrats[0]
    contrats.each do |c|
      critical_contract = c if engagement(c.id).correction < engagement(critical_contract.id).correction
    end
    # Not very DRY: present in lib/comex_resultat too
    amplitude = self.contrat.heure_fermeture - self.contrat.heure_ouverture
    if critical_contract.blank?
      temps_correction = 0.days
    else
      temps_correction = engagement( critical_contract.id ).correction.days
    end

    temps_reel=
      distance_of_time_in_working_days(temps_ecoule, amplitude)
    temps_prevu_correction=
      distance_of_time_in_working_days(temps_correction,amplitude)
    if temps_reel > temps_prevu_correction
      distance_of_time_in_french_words(temps - temps_correction,
                                       self.contrat)<<
      _(' of overrun')
    else
      distance_of_time_in_french_words(temps, self.contrat)
    end
  end

#  private
  def affiche_delai(temps_passe, delai)
    value = calcul_delai(temps_passe, delai)
    return "-" if value == 0
    distance = distance_of_time_in_french_words(value.abs, self.contrat)
    if value >= 0
      "<p style=\"color: green\">#{distance}</p>"
    else
      "<p style=\"color: red\">#{distance}</p>"
    end
  end

  def calcul_delai(temps_passe, delai)
    return 0 if delai == -1
    - (temps_passe - delai * contrat.interval_in_seconds)
  end

  def compute_temps_ecoule(to = nil)
    return 0 unless commentaires.size > 0
    contrat = self.contrat
    changes = commentaires # Demandechange.find(:all)
    statuts_sans_chrono = [ 3, 7, 8 ] #Suspendue, Cloture, Annulée, cf modele statut
    inf = { :date => self.created_on, :statut => changes.first.statut_id } #1er statut : enregistré !
    delai = 0
    for c in changes
      sup = { :date => c.updated_on, :statut => c.statut_id }
      unless statuts_sans_chrono.include? inf[:statut]
        delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]),
                              Jourferie.get_dernier_jour_ouvre(sup[:date]),
                              contrat)
      end
      inf = sup
      break if to == inf[:statut]
    end

    unless statuts_sans_chrono.include? self.statut.id and to != nil
      sup = { :date => Time.now, :statut => self.statut_id }
      delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]),
                            Jourferie.get_dernier_jour_ouvre(sup[:date]),
                            contrat)
    end
    delai
  end

  ##
  # Calcule le différentiel en secondes entre 2 jours,
  # selon les horaires d'ouverture du contrat et les jours fériés
  def compute_diff(dateinf, datesup, contrat)
    return 0 unless contrat
    borneinf = dateinf.beginning_of_day
    bornesup = datesup.beginning_of_day
    nb_jours = Jourferie.nb_jours_ouvres(borneinf, bornesup)
    result = 0
    if nb_jours == 0
      return compute_diff_day(dateinf, datesup, contrat)
#       borneinf = dateinf
#       bornesup = datesup.change(:mday => dateinf.day,
#                                 :month => dateinf.month,
#                                 :year => dateinf.year)
    else
      result = ((nb_jours-1) * contrat.interval_in_seconds)
    end
    borneinf = borneinf.change(:hour => contrat.heure_fermeture)
    bornesup = bornesup.change(:hour => contrat.heure_ouverture)

    # La durée d'un jour ouvré dépend des horaires d'ouverture
    result += compute_diff_day(dateinf, borneinf, contrat)
#     puts 'dateinf ' + dateinf.to_s + ' borneinf ' + borneinf.to_s + ' result 1 : ' + compute_diff_day(dateinf, borneinf, contrat).to_s
    result += compute_diff_day(bornesup, datesup, contrat)
#     puts 'bornesup ' + bornesup.to_s + ' datesup ' + datesup .to_s + ' result 2 : ' +  compute_diff_day(bornesup, datesup, contrat).to_s
    result
  end

  ##
  # Calcule le temps en seconde qui est écoulé durant la même journée
  # En temps ouvré, selon les horaires du contrat
  def compute_diff_day(jourinf, joursup, contrat)
    # mise au minimum à 7h
    borneinf = jourinf.change(:hour => contrat.heure_ouverture)
    jourinf = borneinf if jourinf < borneinf
    # mise au minimum à 19h
    bornesup = joursup.change(:hour => contrat.heure_fermeture)
    joursup = bornesup if joursup > bornesup
    #on reste dans les bornes
    return 0 unless jourinf < joursup
    (joursup - jourinf)
  end

  # FONCTION vers lib/lstm.rb:time_in_french_words
  def distance_of_time_in_french_words(distance_in_seconds, contrat)
    dayly_time = contrat.heure_fermeture - contrat.heure_ouverture # in hours
    Lstm.time_in_french_words(distance_in_seconds, dayly_time)
  end

  # Calcule en JO (jours ouvrés) le temps écoulé
  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f
  end


  protected
  # this method must be protected and cannot be private as Ruby 1.8.6
  def appellee
#     @appellee ||= self.versions.find(:first, :conditions => 'statut_id=2',
#                                     :order => 'updated_on ASC')
    @appellee ||= self.commentaires.find(:first, :conditions => 'statut_id=2',
                                         :order => 'updated_on ASC')
  end


end
