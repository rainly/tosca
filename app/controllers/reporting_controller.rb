class ReportingController < ApplicationController
  require 'digest/sha1'
  model   :identifiant
  layout  'standard-layout'

  @@titres = { 
    :repartition => 'R�partition des demandes re�ues',
    :repartition_cumulee => 'R�partition des demandes re�ues',
    :severite => 'S�v�rit� des demandes re�ues',
    :severite_cumulee => 'S�v�rit� des demandes re�ues',
    :resolution => 'R�solution des demandes re�ues',
    :resolution_cumulee => 'R�solution des demandes re�ues',
    :evolution => 'Evolution des sollicitations distinctes',
    :top5_demandes => 'Top 5 des demandes les plus discut�es',
    :top5_logiciels => 'Top 5 des logiciels les plus d�fectueux',
    :temps_rappel => 'Evolution du temps de prise en compte',
    :temps_contournement => 'Evolution du temps de contournement',
    :temps_correction => 'Evolution du temps de correction'
    }

  @@couleurs = [ nil, "#225588", "#228822", "#ee0000", "#bb88bb", "#be4800" ]
  # clair, fonc�, ...
  @@couleurs_degradees = [nil, "#225588", "#336699", "#228822", "#339933", 
    "#ee0000", "#ff0000", "#bb88bb", "#cc99cc", "#be4800", "#cf5910" ]

  def index
    general
    render :action => 'configuration'
  end

  # utilis� avant l'affichage
  def configuration
    @contrats = (@beneficiaire ? @beneficiaire.client.contrats : 
                   Contrat.find(:all, Contrat::OPTIONS))
  end

  # deprecated
  # TODO : effacer
 #  def delai
#     report_delai

#     @clients.each do |c| 
#       write_graph(:"temps_rappel_#{c.id}", Gruff::Line)
#       write_graph(:"temps_contournement_#{c.id}", Gruff::Line) 
#       write_graph(:"temps_correction_#{c.id}", Gruff::Line)
#     end
#   end

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
#     write_graph(:repartition, Gruff::StackedBar)
#     write_graph(:severite, Gruff::StackedBar)
#     write_graph(:resolution, Gruff::StackedBar)
#     write_graph(:evolution, Gruff::Line)
#     write_graph(:annulation, Gruff::Line)

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
    @report[:start_date] = [@contrat.ouverture, Time.now].min
    @report[:end_date] = [Time.now, @contrat.cloture].min
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
    middle_date = end_date.months_ago(params[:reporting][:period].to_i)
    @report[:middle_date] = [ middle_date, @report[:start_date] ].max
    @report[:middle_report] = ((end_date - @report[:middle_date]) / 1.month).round
    @report[:total_report] = ((end_date - @report[:start_date]) / 1.month).round
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
      [ [:corrigee], [:cloturee], [:annulee], [:en_cours] ]
    @data[:evolution] = 
      [ [:beneficiaires], [:logiciels], [:correctifs] ] # TODO : [:interactions]
    @data[:annulation] = 
      [ [:informations], [:anomalies], [:evolutions] ]
#     @data[:temps_de_rappel] =
#       [ [:dans_les_delais], [:hors_delai] ]
    # Camemberts nomm� dynamiquement
#    @data[:top5_logiciels] = [ ]
#    @data[:top5_demandes] = [ ] 

#     # Camemberts statiques
#     @data[:repartition_cumulee] = 
#       [ [:anomalies], [:informations], [:evolutions] ]
#     @data[:severite_cumulee] = 
#       [ [:bloquante], [:majeure], [:mineure], [:sansobjet] ]
#     @data[:resolution_cumulee] = 
#       [ [:cloturee], [:annulee], [:en_cours] ]
  end

#   def init_delai
#     # SideBar sur l'ensemble
#     @clients.each do |c|
#       @data[:"temps_rappel_#{c.id}"] =
#         [ [:minimum], [:moyenne], [:maximum] ]
#       @data[:"temps_contournement_#{c.id}"] =
#         [ [:minimum], [:moyenne], [:maximum] ]
#       @data[:"temps_correction_#{c.id}"] =
#         [ [:minimum], [:moyenne], [:maximum] ]
#     end
#   end

  # TODO : effacer apres refactoring
#   def report_delai
#     start_date = Time.mktime
#     end_date = Time.mktime(start_date.year, 12)

#     @dates = {}
#     i = 0
#     until (start_date > end_date) do 
#       infdate = "'" + start_date.strftime('%y-%m') + "-01'"
#       supdate = "'" + (start_date.advance(:months => 1)).strftime('%y-%m') + "-01'"
      
#       @conditions = [ 'created_on BETWEEN ? AND ? ', infdate, supdate ]
#       date = start_date.strftime('%b')
#       @dates[i] = date
#       i += 1
#       Demande.with_scope({ :find => { :conditions => @conditions } }) do
#         @clients.each do |c|
#           liste = c.beneficiaires.collect{|b| b.id}.join(',')
#           conditions = [ "demandes.beneficiaire_id IN (#{liste})" ] unless liste == ''
#           Demande.with_scope({ :find => { :conditions => conditions } }) do
#             compute_temps @data, c
#           end
#         end
#       end
#       start_date = start_date.advance(:months => 1)
#     end
#   end

  # Remplit un tableau avec la somme des donn�es sur nb_month
  # Call it like : middle_period = compute_data_period('middle', 3)
  def compute_data_period(period, nb_month)
    start = -nb_month
    data = {}
    @data.each_key do |key|
      mykey = :"#{key}_#{period}"
      data[mykey] = []
      @data[key].each do |value|
        result = []
        result.push value[0]
        result.push value[start..-1].inject(0){|s, v| s + v}
        data[mykey].push result
      end
    end
    data
  end

  def fill_data_general
    start_date = @report[:start_date]
    end_date = @report[:end_date]

    conditions = [ 'created_on BETWEEN ? AND ?', nil, nil ]  
    until (start_date > end_date) do 
      infdate = "#{start_date.strftime('%y-%m')}-01"
      start_date = start_date.advance(:months => 1)
      supdate = "#{start_date.strftime('%y-%m')}-01"
      
      conditions[1], conditions[2] = infdate, supdate
      Demande.with_scope({ :find => { :conditions => conditions } }) do
        compute_repartition @data[:repartition]
        compute_severite @data[:severite]     
        compute_resolution @data[:resolution]
        compute_annulation @data[:annulation]
#        compute_temps_de_rappel @data[:temps_de_rappel]
        Correctif.with_scope({:find => {:conditions => conditions }}) do
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
#     end_date = start_date
#     start_date = Time.mktime(@annee) 
#     infdate = "'" + start_date.strftime('%y-%m') + "-01'"
#     supdate = "'" + end_date.strftime('%y-%m') + "-01'"
#     @conditions = [ 'created_on BETWEEN ? AND ? ', infdate, supdate ]
#     @demande_ids = Demande.find(:all, :select => 'demandes.id').join(',')
#     Demande.with_scope({ :find => { :conditions => @conditions } }) do
#       compute_repartition @data[:repartition_cumulee]
#       compute_severite @data[:severite_cumulee]
#       compute_resolution @data[:resolution_cumulee]

#       compute_top5_logiciels @data[:top5_logiciels]
#       Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
#         compute_top5_demandes @data[:top5_demandes]
#       end
#     end
  end


  ##
  # Sort une moyenne de nos traitements des demandes
  # Sort le temps maximum de nos traitements des demandes
  def fill_report(temps, report)
    report[0].push((temps.size == 0 ? 0 : temps.min)) # .floor))
    report[1].push((temps.size == 0 ? 0 : avg(temps))) # .round))
    report[2].push((temps.size == 0 ? 0 : temps.max)) # .ceil))
  end


  def compute_temps(donnees, client)
    demandes = Demande.find_all

    rappels, contournements, corrections = [], [], []
    demandes.each do |d|
      rappels.push d.temps_rappel / 60
      contournements.push distance_of_time_in_working_days(d.temps_contournement,client.support)
      corrections.push distance_of_time_in_working_days(d.temps_correction,client.support)
    end
    report = donnees[:"temps_rappel_#{client.id}"]
    fill_report(rappels, report)

    report = donnees[:"temps_contournement_#{client.id}"]
    fill_report(contournements, report)

    report = donnees[:"temps_correction_#{client.id}"]
    fill_report(corrections, report)
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
    informations = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 2 ] }
    anomalies = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 1 ] }
    evolutions = { :conditions => [ 'statut_id = 8 AND typedemande_id = ?', 5 ] }

    report[0].push Demande.count(informations)
    report[1].push Demande.count(anomalies)
    report[2].push Demande.count(evolutions)
  end


  ##
  # Compte les demandes selon leur nature
  def compute_repartition(report)
    # TODO : faire des requ�tes param�tr�es, avec des ?
    informations = { :conditions => "typedemande_id = 2" }
    anomalies = { :conditions => "typedemande_id = 1" }
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
    corrigee = { :conditions => [condition, 6] }
    cloturee = { :conditions => [condition, 7] }
    annulee = { :conditions => [condition, 8] }
    en_cours = { :conditions => 'statut_id NOT IN (6,7,8)' }

    report[0].push Demande.count(corrigee)
    report[1].push Demande.count(cloturee)
    report[2].push Demande.count(annulee)
    report[3].push Demande.count(en_cours)
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

    if title; g.title = title; else g.hide_title = true; end
    g.theme_37signals
    g.colors = @colors[nom]
    g.sort = false
    # g.font =  File.expand_path('public/font/VeraBd.ttf', RAILS_ROOT)
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
  def distance_of_time_in_working_days(distance_in_seconds, support)
    distance_in_minutes = ((distance_in_seconds.abs)/60.0)
    jo = (support.fermeture - support.ouverture) * 60.0
    distance_in_minutes.to_f / jo.to_f 
  end


  def scope_beneficiaire
    if @beneficiaire
      liste = @beneficiaire.client.beneficiaires.collect{|b| b.id}.join(',')
      conditions = [ "demandes.beneficiaire_id IN (#{liste})" ]
      Demande.with_scope({ :find => { 
                             :conditions => conditions
                          }
                        }) { yield }
    else
      yield
    end
  end

  # TODO : on efface cette fonction ?
  def report_mensuel(start_date, end_date = Time.now)
    init_general unless @data

    @dates = {}
    i = 0
    until (start_date > end_date) do 
      infdate = "'" + start_date.strftime('%y-%m') + "-01'"
      supdate = "'" + (start_date.advance(:months => 1)).strftime('%y-%m') + "-01'"
      
      @conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
      date = start_date.strftime('%b')
      @dates[i] = date
      i += 1
      Demande.with_scope({ :find => { :conditions => @conditions } }) do
        compute_repartition @data[:repartition]
        compute_severite @data[:severite]     
        compute_resolution @data[:resolution]
        compute_evolution @data[:evolution]
      end
      start_date = start_date.advance(:months => 1)
    end

    end_date = start_date
    start_date = Time.mktime(@annee) 
    infdate = "'" + start_date.strftime('%y-%m') + "-01'"
    supdate = "'" + end_date.strftime('%y-%m') + "-01'"
    @conditions = [ "created_on BETWEEN #{infdate} AND #{supdate}" ]
    # @demande_ids = Demande.find(:all, :select => 'demandes.id').join(',')
    Demande.with_scope({ :find => { :conditions => @conditions } }) do
      compute_repartition @data[:repartition_cumulee]
      compute_severite @data[:severite_cumulee]
      compute_resolution @data[:resolution_cumulee]

      compute_top5_logiciels @data[:top5_logiciels]
      Commentaire.with_scope({ :find => { :conditions => @conditions } }) do
        compute_top5_demandes @data[:top5_demandes]
      end
    end
  end

end
