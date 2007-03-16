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
  has_and_belongs_to_many :paquets
  # TODO : à voir si c'est inutile. avec le socle, on a dejà la plateforme
  has_and_belongs_to_many :binaires
  has_and_belongs_to_many :appels
  has_many :commentaires, :order => "updated_on DESC", :dependent => :destroy
  belongs_to :contribution
  belongs_to :socle
  has_many :piecejointes, :through => :commentaires


  validates_presence_of :resume, 
       :warn => "Vous devez indiquer un résumé de votre demande"
  validates_length_of :resume, :within => 3..60
  validates_presence_of :logiciel, 
       :warn => "Vous devez indiquer le logiciel concerné"

  #versioning, qui s'occupe de la table demandes_versions
  acts_as_versioned

  # Corrigées, Cloturées et Annulées
  # MLO : on met un '> 6' à la place du 'IN' ?
  TERMINEES = 'demandes.statut_id IN (5,6,7,8)'
  EN_COURS = 'demandes.statut_id NOT IN (5,6,7,8)'

  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions => 
        [ 'beneficiaires.client_id IN (?)', client_ids],
        :include => [:beneficiaire]} }
  end

  # return the condition of the scope.
  # Used in controller demande for the speed n dirty hack finder
  # on list actions
  def self.get_scope_without_include(client_ids)
    { :find => { :conditions => 
        [ 'beneficiaires.client_id IN (?)', client_ids]} }
  end

  def to_param
    "#{id}-#{resume.gsub(/[^a-z1-9]+/i, '-')}"
  end


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
        c.name =~ /(_id|_on|version|resume|description|reproductible)$/ || c.name == inheritance_column } 
  end

  def client
    @client ||= ( beneficiaire ? beneficiaire.client : nil )
    @client
  end

  def reproduit
    if reproductible then 'Oui' else 'Non' end
  end

  def respect_contournement(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).contournement)
  end

  def respect_correction(contrat_id)
    affiche_delai(temps_ecoule, engagement(contrat_id).correction)
  end


  def affiche_temps_correction
    distance_of_time_in_french_words(self.temps_correction, client.support)
  end

  def temps_correction
    result = 0
    corrigee = self.versions.find(:first, :conditions => 'statut_id=6', :order => 'updated_on ASC')
    if corrigee
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      if appellee
        result = compute_diff(appellee.updated_on, corrigee.updated_on, client.support)
      end
    end
    result
  end

  def affiche_temps_contournement
    distance_of_time_in_french_words(self.temps_contournement, client.support)
  end

  def temps_contournement
    result = 0
    contournee = self.versions.find(:first, :conditions => 'statut_id=5', :order => 'updated_on ASC')
    if contournee
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      result = compute_diff(appellee.updated_on, contournee.updated_on, client.support)
    end
    result
  end

  def affiche_temps_rappel
    distance_of_time_in_french_words(self.temps_rappel, client.support)
  end

  def temps_rappel
    result = 0
    first = self.versions[0]
    if (self.versions.size > 2) and (first.statut_id == 1)
      appellee = self.versions.find(:first, :conditions => 'statut_id=2', :order => 'updated_on ASC')
      result = compute_diff(first.updated_on, appellee.updated_on, client.support)
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
  def affiche_temps_ecoule
    temps = temps_ecoule
    temps==-1 ? "sans engagement" :
      distance_of_time_in_french_words(temps, client.support)
  end


#  private
  def affiche_delai(temps_passe, delai)
    value = calcul_delai(temps_passe, delai)
    return "N/A" if value == 0
    distance = distance_of_time_in_french_words(value.abs, client.support)
    if value >= 0
      "<p style=\"color: green\">#{distance}</p>"
    else
      "<p style=\"color: red\">#{distance}</p>"
    end
  end

  def calcul_delai(temps_passe, delai)
    return 0 if delai == -1
    - (temps_passe - delai * client.support.interval_in_seconds)
  end

  def compute_temps_ecoule
    return 0 unless self.versions.size > 0
    support = client.support
    changes = self.versions # Demandechange.find_all_by_demande_id(self.id, :order => "created_on")
    statuts_sans_chrono = [ 3, 7, 8 ] #Suspendue, Cloture, Annulée, cf modele statut
    inf = { :date => self.created_on, :statut => changes.first.statut_id } #1er statut : enregistré !
    delai = 0
    for c in changes
      sup = { :date => c.updated_on, :statut => c.statut_id }
#      delai += (sup[:date] - inf[:date]).to_s + " de " + inf[:statut].nom + " à " + sup[:statut].nom + "<br />"
      unless statuts_sans_chrono.include? sup[:statut]
        delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]), 
                              Jourferie.get_dernier_jour_ouvre(sup[:date]), 
                              support)
      end
      inf = sup
    end

    if not statuts_sans_chrono.include? self.statut.id
      sup = { :date => Time.now, :statut => self.statut_id }
      delai += compute_diff(Jourferie.get_premier_jour_ouvre(inf[:date]), 
                            Jourferie.get_dernier_jour_ouvre(sup[:date]), 
                            support)
    end
    delai
  end


  ##
  # Calcule le différentiel en secondes entre 2 jours,
  # selon les horaires d'ouverture du 'support' et les jours fériés
  def compute_diff(dateinf, datesup, support)
    return 0 unless support
    borneinf = dateinf.beginning_of_day
    bornesup = datesup.beginning_of_day
    nb_jours = Jourferie.nb_jours_ouvres(borneinf, bornesup)
    result = 0
    if nb_jours == 0
      borneinf = dateinf
      bornesup = datesup.change(:mday => dateinf.day,
                                :month => dateinf.month,
                                :year => dateinf.year)
    else
      result = ((nb_jours-1) * support.interval_in_seconds) 
      borneinf = borneinf.change(:hour => support.fermeture)
      bornesup = bornesup.change(:hour => support.ouverture)
    end
    # La durée d'un jour ouvré dépend des horaires d'ouverture
    result += compute_diff_day(dateinf, borneinf, support)
    result += compute_diff_day(bornesup, datesup, support)
    result
  end

  ##
  # Calcule le temps en seconde qui est écoulé durant la même journée
  # En temps ouvré, selon les horaires du 'support'
  def compute_diff_day(jourinf, joursup, support)
    #on recup les bornes selon le niveau de support
    borneinf = jourinf.change(:hour => support.ouverture)
    bornesup = joursup.change(:hour => support.fermeture)
    #on reste dans les bornes
    jourinf = borneinf if jourinf < borneinf
    joursup = bornesup if joursup > bornesup
    return 0 unless jourinf < joursup
    (joursup - jourinf)
  end

  # Reports the approximate distance in time between two Time objects or integers. 
  # For example, if the distance is 47 minutes, it'll return
  # "about 1 hour". See the source for the complete wording list.
  #
  # Integers are interpreted as seconds. So,
  # <tt>distance_of_time_in_words(50)</tt> returns "less than a minute".
  #
  # Set <tt>include_seconds</tt> to true if you want more detailed approximations if distance < 1 minute
  
  # J'ai juste traduis les mots, la fonction est nickel :)
  # Dupliqué avec le helper d'application
  # TODO : être DRY, ca n'a rien à faire dans un model
  def distance_of_time_in_french_words(distance_in_seconds, support)
    distance_in_minutes = ((distance_in_seconds.abs)/60).round
    jo = (support.fermeture - support.ouverture) * 60
    demi_jo_inf = (jo / 2) - 60
    demi_jo_sup = (jo / 2) + 60

    case distance_in_minutes
    when 0 : " - "
    when 0..1 then 
      (distance_in_minutes==0) ? "moins d'une minute" : '1 minute'
    when 2..45      then 
      "#{distance_in_minutes} minutes"
    when 46..90     then 
      'environ 1 heure'
    when 90..demi_jo_inf, (demi_jo_sup+1)..jo   then 
      "environ #{(distance_in_minutes.to_f / 60.0).round} heures"
    when (demi_jo_inf+1)..demi_jo_sup
      "1 demi-jour ouvré"
    when jo..(1.5*jo)
       "1 jour ouvré"
    # à partir de 1.5 inclus, le round fait 2 ou plus : pluriel
    else                 
      "#{(distance_in_minutes / jo).round} jours ouvrés"
    end
  end

end
