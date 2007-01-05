module ReportingHelper

  # Renvoit les titres du tableau
  # Data contient les ent�tes. Les options applicable sont :
  # :without_firstcol => permet de ne pas afficher la premi�re colonne
  # :divise => sp�cifie si on prends en compte les demandes vivantes 
  # :with2rows => affichera les ent�tes sur 2 lignes, il <b>contient</b> l'intitul�
  # TODO : renommer with2rows en title
  def fill_titles(data, options)
    size = (options[:divise] ? data.size / 2 : data.size)
    result = ''
    return result unless size > 0
    result << '<tr>'
    first = 'P�riode&nbsp;&nbsp;&nbsp;&nbsp;' 
    if options[:with2rows]
      result << "<th rowspan=\"2\">#{first unless options[:without_firstcol]}</th>" 
      result << "<th nowrap colspan=\"#{size}\">#{options[:with2rows]}</th>"
      result << '</tr><tr>'
      size.times do |t|
        result << '<th nowrap>'
        result << data[t][0].to_s.gsub(/_(terminees|en_cours)/, '').gsub('_','&nbsp;').capitalize
        result << '</th>'
      end
    else
      titres = []
      titres.push first unless options[:without_firstcol]
      size.times do |t|
        titres.push data[t][0].to_s.gsub('_', '&nbsp;').capitalize
      end
      titres.each {|t| result << "<th nowrap>#{t}</th>" }
    end
    result << '</tr>'
  end

  # �l�ment de reporting : 2 cellules
  # options : one_row, muli_row et titre
  def report_evolution(nom, options={})
    data = @data[nom]
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      options.update(:divise => true)
    end
    table = ''
#    table << '<div id="left">'
    table << '<table width="100%">'
    table << ' <tr>'

    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_graph(nom, options) 
    table << '  </td>'
#    table << '</div>'

    # cellule avec la l�gende
#    table << '<div id="middle">'
    table << '  <td class="report_legend">'
    table <<    report_legend(nom)
    table << '  </td>'
#    table << '</div>'
    # cellule contenant le tableau de donn�es
#    table << '<div id="right">'
    table << '  <td class="report_data">'
    table <<    report_data(nom, options)
    table << '  </td>'
#    table << '</div>'

    table << ' </tr>'
    table << '</table>'
    table
  end


  # permet de comparer deux graphiques :
  # - l'un concernant la periode consid�r�e (� gauche)
  # - l'autre concernant la totalit� depuis le d�but du contrat
  def report_repartition(nom, options= {})
    data = @data[nom]
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      options.update(:divise => true)
    end
    middle = :"#{nom}_middle"
    total = :"#{nom}_total"
    table = ''
    table << '<table class="report_item">'
    table << ' <tr>'
    # cellule contenant le graphique
    table << '  <td class="report_graph">'
    table <<    report_graph(middle, options) 
    table << '  </td>'
    # cellule avec la l�gende
    table << '  <td class="report_legend">'
    table <<    report_legend(nom)
    table << '  </td>'
    # cellule contenant le tableau de donn�es
    table << '  <td class="report_data">'
    table <<    report_graph(total, options)
    table << '  </td>'
    table << ' </tr>'

    unless (nom.to_s =~ /^temps/)
      options.update(:without_firstcol => true)
      table << ' <tr>'
      # cellule contenant le graphique
      table << '  <td class="report_data">'
      table <<    report_data(middle, options) 
      table << '  </td>'
      # cellule vide
      table << '<td></td>'
      # cellule contenant le tableau de donn�es
      table << '  <td class="report_data">'
      table <<    report_data(total, options)
      table << '  </td>'
      table << ' </tr>'
    end 
    table << '</table>'
    table
  end

  def report_legend(nom)
    out = ''
    data = @data[nom].sort{|x,y| x[0].to_s <=> y[0].to_s}
    options = { :without_firstcol => true }
    colors = @colors[nom]
    return out unless colors and colors.size > 0

    out << '<table align="center">'
#    out << '<tr>'
    if (not data.empty? and data[0].to_s =~ /_(terminees|en_cours)/)
      twolines = true 
      size = data.size / 2
    else
      twolines = false
      size = data.size
    end
    size.times do |i|
      index = (twolines ? i*2 : i)
      name = data[index][0].to_s
      head = name.gsub(/_(terminees|en_cours)/, '').gsub('_',' ').capitalize
      out << "<tr><th #{'colspan="2"' if twolines}>#{head}</th></tr>"
      out << '<tr><th>Termin�es</th><th>En&nbsp;cours</th></tr>' if twolines
      out << '<tr>'
      color = colors[index]
      # un <td> quoiqu'il se passe
      out << "<td bgcolor=\"#{color}\">&nbsp;</td>"
      # un autre si twolines
      if twolines
        color = colors[index+1]
        out << "<td bgcolor=\"#{color}\">&nbsp;</td>"
      end
      out << '</tr>'
    end
    out << '</table>' # << '</tr>'
  end

  # graphique
  # options : titre
  def report_graph(nom, options={})
    out = ''
    if options[:titre]
      out << image_tag(@path[nom], :alt => options[:titre])
    else
      out << image_tag(@path[nom], :alt => @titres[nom])
    end
    out
  end 

  # tableau de donn�es
  # options : one_row, muli_row
  def report_data(nom, options={})
    out = ''
    data = @data[nom]
    if options[:without_firstcol]
      first_col = [nil]
    else
      first_col = @first_col
    end
    options.update(:width => '5%')
    out << show_report_table(first_col, nom, 
                             fill_titles(data, options), 
                             options) 
    out
  end 


  # Affiche les tableaux de reporting.
  # 2 options possible :
  # :without_firstcol d�sactive la premi�re colonne, des dates
  # :divise permet de n'afficher que la moiti� des colonnes 
  # :width sp�cifie la taille du tableau
  # pour les tableaux contenant les informations des demandes 
  # en cours et des demandes termin�es
  # TODO : first_col, options[:without_firstcol] : � refactorer
  def show_report_table(first_col, nom, titres, options = {})
    elements = @data[nom]
    return 'aucune donn�e' unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : '' )
    result = "<table #{width}>"
    # C'est sens� dire au navigateur d'aligner sur la virgule
    # RESULT : ca marche po, on garde ?
    result << '<colgroup><col><col align="char" char="."></colgroup>'
    result << titres

    size = (options[:divise] ? (elements.size / 2) : elements.size)
    first_col.each_index { |i| 
      result << "<tr class=\"#{(i % 2)==0 ? 'pair':'impair'}\">"
      result << "<td>#{first_col[i] unless options[:without_firstcol]}</td>" 

      size.times do |c|
        en_cours = (options[:divise] ? elements[c+size][i + 1] : 0)
        total = elements[c][i + 1] + en_cours
        if (total.is_a? Float) 
            total = (total==0.0 ? '-' : "#{total.round}\%")
        end
        result << "<td>#{total}"
        result << " (#{en_cours})" if en_cours != 0 
        result << "</td>"
      end
      i += 1
      result << '</tr>'
    }
    result << '</tr></table>'
  end
end
