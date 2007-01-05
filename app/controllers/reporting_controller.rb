class ReportingController < ApplicationController
  require 'digest/sha1'
  model   :identifiant
  layout  'standard-layout'

  @@titres = { 
    :repartition => 'R�partition des demandes re�ues',
    :repartition_cumulee => 'R�partition des demandes re�ues',
    :severite => 'S�v�rit� des demandes re�ues', 
    :severite_cumulee => 'S�v�rit� des demandes re�ues',
    :resolution => 'R�solution des demandes re�ues', #Etat actuel de vos demandes
    :resolution_cumulee => 'R�solution des demandes re�ues',

    :annulation => 'Demandes annul�es',
    :evolution => 'Evolution des sollicitations distinctes', #Evolution des acc�s au service
 
    :top5_demandes => 'Top 5 des demandes les plus discut�es',
    :top5_logiciels => 'Top 5 des logiciels les plus d�fectueux',

    :temps_de_rappel => 'Evolution du temps de prise en compte', #Temps de rappel 
    :temps_de_contournement => 'Evolution du temps de contournement',
    :temps_de_correction => 'Evolution du temps de correction'
    }



# Pour respecter ordre alpha des severit�s : bloquante, majeure, mineure, sans objet, ...
  colors =  [
    # clair, fonc�, ...
    "#dd0000", "#ff2222", #rouge
    "#dd8242", "#ffa464", #orange
    "#dddd00", "#ffff22", #jaune
    "#84dd00", "#a6ff22", #vert
    "#0082dd", "#22a4ff", #bleu
  ]
  @@couleurs_degradees = ( [nil] << colors ).flatten
  @@couleurs = ( [nil] << colors.indexes(1, 3, 5, 7, 9) ).flatten
  @@couleurs_delais = ( [nil] << colors.indexes(7, 1) ).flatten

  def index
    general
    render :action => 'configuration'
  end

  # utilis� avant l'affichage
  def configuration
    @contrats = (@beneficiaire ? @beneficiaire.client.contrats : 
                   Contrat.find(:all, Contrat::OPTIONS))
  end


  def general

    return redirect_to(:action => 'configuration') unless params[:reporting]
    init_class_var(params)
    return redirect_to(:action => 'configuration') unless 
      @report[:start_date] < @report[:end_date]
    init_data_general
    fill_data_general
    # TODO : trouver un bon moyen de faire un cache
    @data.each_pair do |nom, data| # each_key do |nom|
      #sha1 = Digest::SHA1.hexdigest("-#{qui}-#{nom}-")
      @path[nom] = "reporting/#{nom}.png"
      size = data.size 
      if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
        @colors[nom] = @@couleurs_degradees[1..size]
      elsif nom.to_s =~ /^temps/
        @colors[nom] = @@couleurs_delais[1..size]
      else
        @colors[nom] = @@couleurs[1..size]
      end
    end


    #on nettoie 
    # TODO retravailler le nettoyage
    # reporting = File.expand_path('public/reporting', RAILS_ROOT)
    # rmtree(reporting)
    # Dir.mkdir(reporting)

    # on remplit
    je_veux_mettre_a_jour_les_graphes = false
    if (je_veux_mettre_a_jour_les_graphes)
     write_graph(:repartition, Gruff::StackedBar)
     write_graph(:severite, Gruff::StackedBar)
     write_graph(:resolution, Gruff::StackedBar)
     write_graph(:evolution, Gruff::Line)
     write_graph(:annulation, Gruff::Line)
     write_graph(:temps_de_rappel, Gruff::Line)
     write_graph(:temps_de_contournement, Gruff::Line)
     write_graph(:temps_de_correction, Gruff::Line)
    end
      
#     write_graph(:top5_demandes, Gruff::Pie)
#     write_graph(:top5_logiciels, Gruff::Pie)
    # on nettoie
    @first_col.each { |c| c.gsub!('\n','') }
  end

  private

  # initialise toutes les variables de classes n�cessaire
  # path stocke les chemins d'acc�s, @donn�es les donn�es
  # @first_col contient la premi�re colonne et @contrat le contrat
  # s�lectionn�
  def init_class_var(params)
    @contrat = Contrat.find(params[:reporting][:contrat_id])
    @data, @path, @report, @colors = {}, {}, {}, {}
    @titres = @@titres
    @report[:start_date] = [@contrat.ouverture.beginning_of_month, Time.now].min
    @report[:end_date] = [Time.now, @contrat.cloture.beginning_of_month].min
    @first_col = []
    current_month = @report[:start_date]
    end_date = @report[:end_date]
    while (current_month < end_date) do
      @first_col.push current_month.strftime('%b \n%Y')
      current_month = current_month.advance(:months => 1)
    end
    @labels = {}
    i = 0
    @first_col.each do |c|
      @labels[i] = c if ((i % 2) == 0)
      i += 1
    end
    middle_date = end_date.months_ago(params[:reporting][:period].to_i - 1)
    start_date = @report[:start_date]
    @report[:middle_date] = [ middle_date, start_date ].max.beginning_of_month
    @report[:middle_report] = ((end_date - @report[:middle_date]) / 1.month).round + 1
    @report[:total_report] = ((end_date - start_date) / 1.month).round + 1  
  end

  # initialisation de @data
  def init_data_general
    # R�partions par mois (StackedBar)
    # _terminees doit �tre en premier
    @data[:repartition]  = 
      [ [:informations_terminees], [:anomalies_terminees], 
      [:evolutions_terminees], [:informations_en_cours], 
      [:anomalies_en_cours], [:evolutions_en_cours] ]
    @data[:severite] = 
      [ [:bloquante_terminees], [:majeure_terminees], 
      [:mineure_terminees], [:sans_objet_terminees],
      [:bloquante_en_cours], [:majeure_en_cours], 
      [:mineure_en_cours], [:sans_objet_en_cours] ]
    @data[:resolution] = 
      [ [:contournee], [:corrigee], [:cloturee], [:annulee], [:en_cours] ]
    @data[:evolution] = 
      [ [:beneficiaires], [:logiciels], [:correctifs] ] # TODO : [:interactions]
    @data[:annulation] = 
      [ [:informations], [:anomalies], [:evolutions] ]

    # calcul des d�lais
     @data[:temps_de_rappel] =
      [ [:delais_respectes], [:hors_delai] ]
     @data[:temps_de_contournement] =
      [ [:delais_respectes], [:hors_delai] ]
     @data[:temps_de_correction] =
      [ [:delais_respectes], [:hors_delai] ]


    # Camemberts nomm� dynamiquement
#    @data[:top5_logiciels] = [ ]
#    @data[:top5_demandes] = [ ] 
  end

  # Remplit un tableau avec la somme des donn�es sur nb_month
  # Call it like : middle_period = compute_data_period('middle', 3)
  def compute_data_period(period, nb_month)
    start = -nb_month
    data = {}
    @data.each_key do |key|
      mykey = :"#{key}_#{period}"
      data[mykey] = []
      ponderation = (key.to_s =~ /^temps/) ? true : false
      @data[key].each do |value|
        result = []
        result.push value[0]
        if ponderation
          result.push value[start..-1].inject(0){|s, v| s + v}
          result[result.size - 1] /= nb_month # total if total != 0
        else
          result.push value[start..-1].inject(0){|s, v| s + v}
        end
        data[mykey].push result
      end
    end
    data
  end

  def fill_data_general
    start_date = @report[:start_date]
    end_date = @report[:end_date]

    liste = @contrat.client.beneficiaires.collect{|b| b.id} # .join(',')
    demandes = [ 'demandes.created_on BETWEEN ? AND ? AND demandes.beneficiaire_id IN (?)',
      nil, nil, liste ]  
    correctifs = [ 'correctifs.created_on BETWEEN ? AND ?', nil, nil ]  
    # (#{liste})" ]
    until (start_date > end_date) do 
      infdate = "#{start_date.strftime('%y-%m')}-01"
      start_date = start_date.advance(:months => 1)
      supdate = "#{start_date.strftime('%y-%m')}-01"
      
      demandes[1], demandes[2] = infdate, supdate
      Demande.with_scope({ :find => { :conditions => demandes } }) do
        compute_repartition @data[:repartition]
        compute_severite @data[:severite]     
        compute_resolution @data[:resolution]
        compute_annulation @data[:annulation]
        compute_temps @data
        correctifs[1], correctifs[2] = infdate, supdate
        Correctif.with_scope({:find => {:conditions => correctifs }}) do
          compute_evolution @data[:evolution]
        end
      end
    end
    # on fais bien attention � ne merger avec @data
    # qu'APRES avoir calcul� toutes les sommes 
    middle_report = compute_data_period('middle', @report[:middle_report])
    total_report = compute_data_period('total', @report[:total_report])

    # Maintenant on peut mettre � jour @data
    @data.update(middle_report)
    @data.update(total_report)
    #TODO : se d�barrasser de cet h�ritage legacy
#       compute_top5_logiciels @data[:top5_logiciels]
#       Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
#         compute_top5_demandes @data[:top5_demandes]
#       end
#     end
  end


  ##
  # Sort une moyenne de nos traitements des demandes
  # Sort le temps maximum de nos traitements des demandes
  def compute_temps(donnees)
    demandes = Demande.find_all
    rappels = donnees[:temps_de_rappel]
    contournements = donnees[:temps_de_contournement]
    corrections = donnees[:temps_de_correction]
    last_index = rappels[0].size 
    2.times {|i| 
      rappels[i].push 0.0
      contournements[i].push 0.0
      corrections[i].push 0.0 
    }

    terminal = [6,7,8]
    support = @contrat.client.support
    amplitude = support.fermeture - support.ouverture
    demandes.each do |d|
      e = d.engagement(@contrat.id)
      next unless e
      
      rappel = d.temps_rappel
      fill_one_report(rappels, rappel, 1.hour, last_index)

      contournement = distance_of_time_in_working_days(d.temps_contournement, amplitude)
      fill_one_report(contournements, contournement, e.contournement, last_index)

      correction = distance_of_time_in_working_days(d.temps_correction, amplitude)
      fill_one_report(corrections, correction, e.correction, last_index)
    end
    
    size = demandes.size
    if size > 0
      size = size.to_f
      2.times {|i| 
        rappels[i][last_index] = (rappels[i][last_index].to_f / size) * 100
        contournements[i][last_index] = (contournements[i][last_index].to_f / size) * 100
        corrections[i][last_index] = (corrections[i][last_index].to_f / size) * 100
      }
    end
  end

  # Petit helper pour �tre dry, je sais pas trop comment l'appeler
  def fill_one_report(collection, value, max, last)
    if value <= max
      collection[0][last] += 1
    else
      collection[1][last] += 1
    end
  end


  ##
  # TODO : le faire marcher si y a moins de 5 logiciels
  # sort les 5 logiciels qui ont eu le plus de demandes
  def compute_top5_logiciels(report)
    logiciels = Demande.count(:group => "logiciel_id")
    logiciels = logiciels.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = logiciels.pop
      nom = Logiciel.find(values[0]).nom
      report.push [ :"#{nom}" ]
      report[i].push values[1]
    end
  end

  ##
  # TODO : le faire marcher si y a moins de 5 demandes
  # Sort les 5 demandes les plus comment�es de l'ann�e
  def compute_top5_demandes(report)
    commentaires = Commentaire.count(:group => 'demande_id')
    commentaires = commentaires.sort {|a,b| a[1]<=>b[1]}
    5.times do |i|
      values = commentaires.pop
      nom = values[0].to_s # "##{values[0]} (#{values[1]})"
      report.push [ :"#{nom}" ]
      report[i].push values[1]
    end
  end

  ##
  # Compte les demandes annul�es selon leur type
  def compute_annulation(report)
    # TODO : faire des requ�tes param�tr�es, avec des ?
    informations = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 1 ] }
    anomalies = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 2 ] }
    evolutions = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 5 ] }

    report[0].push Demande.count(informations)
    report[1].push Demande.count(anomalies)
    report[2].push Demande.count(evolutions)
  end


  ##
  # Compte les demandes selon leur nature
  def compute_repartition(report)
    # TODO : faire des requ�tes param�tr�es, avec des ?
    informations = { :conditions => "typedemande_id = 1" }
    anomalies = { :conditions => "typedemande_id = 2" }
    evolutions = { :conditions => "typedemande_id = 5" }

    Demande.with_scope({ :find => { :conditions => Demande::TERMINEES } }) do
      report[0].push Demande.count(informations)
      report[1].push Demande.count(anomalies)
      report[2].push Demande.count(evolutions)
    end

    Demande.with_scope({ :find => { :conditions => Demande::EN_COURS } }) do
      report[3].push Demande.count(informations)
      report[4].push Demande.count(anomalies)
      report[5].push Demande.count(evolutions)
    end
  end

  ##
  # Compte les demandes par s�v�rit�s
  def compute_severite(report)
    severites = []
    # TODO : requ�te param�tr��, avec ?
    (1..4).each do |i|
      severites.concat [ { :conditions => "severite_id = #{i}" } ]
    end

    Demande.with_scope({ :find => { :conditions => Demande::TERMINEES } }) do
      4.times do |t|
        report[t].push Demande.count(severites[t])
      end
    end
    Demande.with_scope({ :find => { :conditions => Demande::EN_COURS } }) do
      4.times do |t|
        report[t+4].push Demande.count(severites[t])
      end
    end
  end

  ##
  # Compte le nombre de demande Annul�e, Clotur�e ou en cours de traitement
  def compute_resolution(report)
    condition = 'demandes.statut_id = ?'
    contournee = { :conditions => [condition, 5] }
    corrigee = { :conditions => [condition, 6] }
    cloturee = { :conditions => [condition, 7] }
    annulee = { :conditions => [condition, 8] }
    en_cours = { :conditions => 'statut_id NOT IN (5,6,7,8)' }

    report[0].push Demande.count(contournee)
    report[1].push Demande.count(corrigee)
    report[2].push Demande.count(cloturee)
    report[3].push Demande.count(annulee)
    report[4].push Demande.count(en_cours)
  end


  ##
  # Calcule le nombre de beneficiaire, de logiciel et correctif distinct par mois
  def compute_evolution(report)
    # TODO : corriger �a, maintenant on a le contrat
    correctifs = 0
    if @beneficiaire
      ids = @beneficiaire.client.contrats.collect{|c| c.id}.join(',')
      conditions = [ "paquets.contrat_id IN (#{ids})" ]
      joins= 'INNER JOIN correctifs_paquets cp ON cp.correctif_id = correctifs.id ' +
        'INNER JOIN paquets ON cp.paquet_id = paquets.id '
      correctifs = Correctif.count(:conditions => conditions, :joins => joins)
    else
      correctifs = Correctif.count()
    end
    # TODO : distinct ?
    report[0].push Demande.count('beneficiaire_id', :distinct => true)
    report[1].push Demande.count('logiciel_id', :distinct => true)
    report[2].push correctifs
  end


  # Lance l'�criture des 3 graphes
  def write_graph(nom, graph)
    __write_graph(nom, graph)
    middle = :"#{nom}_middle"
    __write_graph(middle, Gruff::Pie, "R�partition sur #{@report[:middle_report]} mois") if @data[middle]
    total = :"#{nom}_total"
    __write_graph(total, Gruff::Pie, "R�partition sur #{@report[:total_report]} mois") if @data[total]
  end
  # Ecrit le graphe en utilisant les donn�es index�es par 'nom' dans @donn�es
  # gr�ce au chemin d'acc�s sp�cifi� dans @path[nom]
  # graph sert � sp�cifier le type de graphe attendu
  def __write_graph(nom, graph, title = 'R�capitulatif')
    return unless @data[nom]
    g = graph.new(450)

    # Trop confus pour l'utilisateur et plus de place pour le graphe
    # if title; g.title = title; else g.hide_title = true; end
    g.hide_title = true
    g.theme = { #    g.theme_37signals l�g�rement modifi�
      :colors => @colors[nom],
      :marker_color => 'black',
      :font_color => 'black',
      :background_colors => ['white', 'white']
    }
    g.sort = false

    data = @data[nom].sort{|x,y| x[0].to_s <=> y[0].to_s}
    data.each {|value| g.data(value[0], value[1..-1]) }
    g.labels = @labels
    g.hide_dots = true if g.respond_to? :hide_dots
    g.hide_legend = true
    # TODO : mettre ca dans les metadatas
    g.no_data_message = 'Aucune donn�e\n n\'est disponible'

    # this writes the file to the hard drive for caching
    g.write "public/images/#{@path[nom]}"
  end

  # TODO : mettre �a dans le mod�le Demande
  # Calcule en JO le temps �coul� 
  def distance_of_time_in_working_days(distance_in_seconds, period_in_hour)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = period_in_hour * 60.0
    distance_in_minutes.to_f / jo.to_f 
  end


end
