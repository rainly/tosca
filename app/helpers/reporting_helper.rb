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
module ReportingHelper
  # Renvoit les titres du tableau
  # Data contient les entêtes. Les options applicable sont :
  # :without_firstcol => permet de ne pas afficher la première colonne
  # :separated => spécifie si on prends en compte les issues vivantes
  # :with2rows => affichera les entêtes sur 2 lignes, il <b>contient</b> l'intitulé
  # TODO : renommer with2rows en title
  def fill_titles(data, options)
    size = (options[:separated] ? data.size / 2 : data.size)
    result = ''
    return result unless size > 0
    result << '<tr>'
    first = (options.has_key?(:distribution) ? _('Status') : _('Period'))
    if options[:with2rows]
      result << %Q{<th rowspan="2">#{first}</th>} unless options[:without_firstcol]
      result << %Q[<th nowrap="nowrap" colspan="#{size}"><div style="text-align: center">#{options[:with2rows]}</div></th>]
      result << '</tr><tr>'
    else
      result << '<th></th>'
    end
    size.times do |t|
      result << %Q{<th nowrap="nowrap">#{data[t][0]}</th>}
    end
    result << '</tr>'
  end

  # élément de reporting : 2 cellules
  # options : one_row, muli_row et titre
  def report_evolution(name, options={})
    @first_col = @months_col
    table = ''
    table << '<table style="width: 100%">'
    table << ' <tr>'

    unless options.has_key?(:without_graph)
      table << '<td>&nbsp;</td>' if options.has_key?(:only_graph)
      table << '<td class="report_graph">'
      table <<   report_graph(name, options)
      table << '</td>'
      table << "<td>&nbsp;</td>"
    end

    unless options.has_key?(:only_graph)
      table << %Q[<td class="report_data" #{'colspan="3"' if options.has_key?(:without_graph)}><div align="center">]
      table <<    report_data(name, options)
      table << '  </div></td>'
    end

    table << ' </tr>'
    table << '</table>'
    table
  end


  # permet de comparer deux graphiques :
  # - l'un concernant la periode considérée (à gauche)
  # - l'autre concernant la totalité depuis le début du contract
  def report_distribution(name, options= {})
    options[:distribution] = true
    if options.has_key? :separated
      @first_col = [ _('Running'), _('Finished') ]
    end
    middle = :"#{name}_middle"
    total = :"#{name}_total"
    table = ''
    table << '<table class="report_item">'
    table << ' <tr>'
    # cellule contenant le graphique de la periode
    table << '  <td class="report_graph" align="center">'
    table << "  <h3>%s</h3>" % _('During the chosen period')
    table <<    report_graph(middle, options)
    table << '  </td>'
    # cellule avec la légende
    table << '  <td class="report_legend"><div align="center">'
    table <<    report_legend(name, options)
    table << '  </div></td>'
    # cellule contenant le graphique depuis le début
    table << '  <td class="report_graph" align="center">'
    table << "  <h3>%s</h3>" % _('Since the beginning of your contract')
    table <<    report_graph(total, options)
    table << '  </td>'
    table << ' </tr>'

    # there's not 2nd part in *_time stuff
    if options.has_key? :with_table
      table << ' <tr>'
      # cellule contenant le graphique
      table << '  <td class="report_data" align="center">'
      table <<    report_data(middle, options)
      table << '  </td>'
      # cellule vide
      table << '<td></td>'
      # cellule contenant le tableau de données
      table << '  <td class="report_data" align="center">'
      table <<    report_data(total, options)
      table << '  </td>'
      table << ' </tr>'
    end
    table << '</table>'
    table
  end

  # Draws the legend graph, according to the <tt>name</tt> index.
  # Options in use :
  # * :separated : used to know if there are double or simple data lines
  def report_legend(name, options)
    out = ''
    data = @data[name] # .sort{|x,y| x[0].to_s <=> y[0].to_s}
    colors = @colors[name]
    return out unless colors and colors.size > 0

    out << '<table align="center">'
    if options.has_key?(:separated)
      twolines = true
      size = data.size / 2
    else
      twolines = false
      size = data.size
    end

    # TODO : put backgrounded cells into the static image helper ?
    # We can then remove the code below
    relative_url_root = "#{ActionController::Base.relative_url_root}/images/reporting/"
    size.times do |i|
      index = (twolines ? i*2 : i)
      head = data[i][0].to_s
      out << "<tr><th #{'colspan="2"' if twolines}>#{head}</th></tr>"
      out << "<tr><th>#{_('Running')}</th><th>#{_('Finished')}</th></tr>" if twolines
      out << '<tr>'
      color = colors[index].to_s
      # un <td> quoiqu'il se passe
      out << "<td bgcolor=\"#{color}\"><img src=\"#{relative_url_root}#{color.gsub('#','x')}.png\" alt=\"#{color}\"/>&nbsp;</td>"
      # un autre si twolines
      if twolines
        color = colors[index+1].to_s
        out << "<td bgcolor=\"#{color}\"><img src=\"#{relative_url_root}#{color.gsub('#','x')}.png\" alt=\"#{color}\"/>&nbsp;</td>"
      end
      out << '</tr>'
    end
    out << '</table>' # << '</tr>'
  end

  # graphique
  # options : titre
  def report_graph(name, options={})
    out = ''
    if options[:titre]
      out << image_tag(@path[name], :alt => options[:titre])
    else
      out << image_tag(@path[name], :alt => @titles[name])
    end
    out
  end

  # tableau de données
  # options : one_row, muli_row
  def report_data(name, options={})
    out = ''
    data = @data[name]
    if options[:without_firstcol]
      first_col = [nil]
    else
      first_col = @first_col
    end
    options.update(:width => '5%')
    # The remove_empty_columns does not know what to do with
    # with 2 rows mechanism
    cleaned_data = (options.has_key?(:separated) ?
                    data : remove_empty_columns(data))
    size = cleaned_data.size
    if options.has_key?(:cut_table) && size >= 4
      cut = size / 2
      out << show_report_table(first_col, cleaned_data[0..cut-1],
        fill_titles(cleaned_data[0..cut-1], options), options)
      out << show_report_table(first_col, cleaned_data[cut..-1],
        fill_titles(cleaned_data[cut..-1], options), options)
    else
      out << show_report_table(first_col, cleaned_data,
        fill_titles(cleaned_data, options), options)
    end
    out
  end

  # Print reporting tables
  # options are :
  # :without_firstcol : disabled the column with the dates
  # :separated : display only half of the columns
  # :width : force the width
  # TODO : first_col, options[:without_firstcol] : needs more love
  def show_report_table(first_col, elements, titles, options = {})
    return _('no data') unless elements and elements.size > 0
    width = ( options[:width] ? %Q{width="#{options[:width]}"} : '' )
    result = "<table #{width}>"
    result << titles


    separated = options.has_key? :separated
    size = (separated ? (elements.size / 2) : elements.size)

    first_col.each_index { |i|
      result << "<tr class=\"#{cycle('even', 'odd')}\">"
      result << "<td>#{first_col[i]}<br /></td>" # unless options[:without_firstcol]

      if options[:with_table]
        size.times do |c|
          pos = (separated ? c*2+i : c)
          result << "<td>#{elements[pos].last}</td>"
        end
      else
        size.times do |c|
          running, total = 0, 0
          if separated
            running = elements[c*2][i + 1]
            total = elements[c*2+1][i + 1]
          else
            total = elements[c][i + 1]
          end
          if (total.is_a? Float)
            total = (total==0.0 ? '-' : "#{total.round}\%")
          end
          result << "<td>#{total}"
          result << " (#{running})" if running != 0
          result << "</td>"
        end
        i += 1
      end
      result << '</tr>'
    }
    result << '</table>'
  end

  # Used in order to hide'em.
  def remove_empty_columns(elements)
    elements.reject do |line|
      there_is_data = false
      line.each do |v|
        next if v.is_a?(String)
        if v.to_i != 0
          there_is_data = true
          break
        end
      end
      !there_is_data
    end
  end

  def progress_image( status, percent )
    return image_sla_exceeded if percent > 1.0
    return image_sla_ok if status
    image_sla_running
  end

  # Display a progress bar colored according to the percentage given in
  # argument. 0% correspond to green, 100% to red and > 100% to black
  # usage : progress_bar(50) display a orange bar, which correspond to 50%
  def progress_bar( percent, desc = _('progress bar') )
    return '-' unless percent and percent.is_a? Numeric
    percent = percent.to_f
    return '-' if !percent.finite? or !percent.between?(0.0, 1.0)
    percent = (percent * 100.0)
    case percent
    when percent < 0.0
      percent = 0.0
    when 0..50.0
      red, green = (255.0*percent/50.0).round , 255.0
    when 50.0..100.0
      red , green = 255.0, (255*(100.0-percent)/50.0).round
    else
      red, green = 0.0, 0.0
    end

    color = "rgb( #{red}, #{green}, 0)"

    result = image_percent(1.23*percent, color, desc)
    result << " (#{(percent).round} %) " if @session_user.engineer?
    result
  end

  def progress_text(elapsed, total, interval)
    result = Time.in_words(elapsed, interval)
    return result if elapsed == nil
    elapsed = Elapsed.relative2absolute(elapsed, interval)
    return _('Exceedance') if @recipient && elapsed > total
    result += " / #{Time.in_words(total)}"
  end

  # Display nicely the issues for the weekly report. See
  # reporting/weekly.rhtml for more information.
  # It takes a list of issues, where client and recipients are preloaded.
  def display_weekly_issues(issues)
    client = nil
    result = '<ol>'
    issues.each do |r|
      if client != r.recipient.client
        result << '</li>' unless client.nil?
        client = r.recipient.client
        result << "<li><b>#{ client.name}</b> :"
      end
      result << ' ' << link_to(r.id.to_s, issue_path(r))
    end
    result << '</li>' if client
    result << '</ol>'
    result
  end

  # Remove some common pattern from a text, in order to reduce it
  # as far as it is possible
  def digest_text(text, size)
    text = html2text(text)
    text.gsub!(/(b|B)onjour.*$/, "")
    text.gsub!(/(c|C)ordialement.*$/, "")
    text.squeeze!(' ') # remove multiple successive whitespace
    text.strip! # remove leading and trailing whitespace removed.
    truncate(text, size)
  end

end
