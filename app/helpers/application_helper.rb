#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

# Methods added to this helper will be available to all templates 
# in the application. Don't ever add a method to this one without a really good 
# reason. Anyway, this is a big helper, so find by keyword :
# - LIENS ABSOLUS
# - LIENS RELATIFS
# - TEXTE
# - FILES
# - LISTES ET TABLES
# - TIME
module ApplicationHelper
  include ImagesHelper
  include PagesHelper
  include FormsHelper
 
  ### LIENS ABSOLUS ############################################################
 
  # lien vers un compte existant
  # DEPRECATED : préferer link_to_edit(id)
  # TODO : passer id en options, avec @session[:user].id par défaut
  # TODO : title en options, avec 'Le compte' par défaut
  def link_to_modify_account(id, title)
    return '' unless id
    options = {:action => 'modify', :controller => 'account', :id => id }
    link_to title, options
  end

  # lien vers mon offre / mon client
  # TODO options[:text] doit prendre l'image si options[:image]
  # options
  # :text texte du lien à afficher
  # :image image du client à afficher à la place
  def link_to_my_client(options = {:text => 'Mon&nbsp;Offre'})
    return nil unless session[:beneficiaire]
    if options[:image]
      link_to image_tag(url_for_file_column(
                  @beneficiaire.client.photo, 'image', 'thumb')),
                  :controller => 'clients', 
                  :action => 'show', :id => session[:beneficiaire].client_id
    else
      link_to options[:text], :controller => 'clients', 
                              :action => 'show', 
                              :id => session[:beneficiaire].client_id
    end
  end

  # Lien vers la consultation d'UN groupe
  def link_to_groupe(groupe)
      link_to groupe.nom, :controller => 'groupes', 
                          :action => 'show', :id => groupe.id
  end

  # Link to access a ticket
  def link_to_comment(ar)
      link_to image_view, { :controller => 'demandes', :action => 'comment',
        :id => ar}, { :class => 'nobackground' }
  end

  # lien vers les contributions
  # action :list ou :admin selon les droits
  def link_to_contributions
    action = (session[:beneficiaire] ? 'list' : 'admin')
    link_to 'Contributions',:controller => 'contributions', :action => action
  end

  # About page
  def public_link_to_about()
    link_to '?', {:controller => 'bienvenue', :action => 'about'}, 
                  :title => _("A propos de #{Metadata::NOM_COURT_APPLICATION}")
  end

  # Link for Richard
  def link_to_admin
    link_to 'Administration', {:controller => 'bienvenue', :action => 'admin'},
            :title => 'Interface d\'administration'
  end

  ### TEXTE #####################################################################

  # indente du texte et échappe les caractères html
  # à utiliser sur les descriptions, commentaires, etc
  def indent( text )
    (text.is_a? String) ? h(text).gsub(/[\n]/, '<br />') : text
  end


  # affiche un message d'aide
  # TODO : mettre une icône
  # TODO : en mettre plus dans les formulaires
  # TODO : changer le curseur en celui avec le '?'
  def show_help( help_text )
    "<a title=\"#{help_text}\" >?</a>"
  end

  ### FILES #####################################################################

  def file_size( file )
    (File.exist?(file) ? number_to_human_size(File.size(file)) : '-' )
  end

  # Call it like this : link_to_file(document, 'fichier', 'nomfichier')
  # don't forget to update his public alter ego just below
  def link_to_file(record, file, options={})
    if record and record.send(file) and File.exist?(record.send(file))
      nom = record.send(file)[/[._ \-a-zA-Z0-9]*$/]
      show = (options[:image] ? image_patch : nom )
      link_to show, url_for_file_column(record, file, :absolute => true)
    else
      options[:else] ||= '-'
    end
  end

  def public_link_to_file(record, file, options={})
    if record and record.send(file) and File.exist?(record.send(file))
      nom = record.send(file)[/[._ \-a-zA-Z0-9]*$/]
      show = (options[:image] ? image_patch : nom )
      html_options = (options[:image] ? {:class => 'no_hover'} : {})
      public_link_to(show, url_for_file_column(record, file, :absolute => true), html_options)
    else
      options[:else] ||= '-'
    end
  end


  ### LISTES ET TABLES ##########################################################

  # Affiche une liste depuis un tableau d'élements
  # Un bloc permet de manipuler un tableau d'objet
  # Options :
  #  * :no_title : DEPRECATED permet de ne pas mettre de titre à la liste
  #  * :title : mettre à false pour ne pas afficher le titre
  #  * :puce : permet d'utiliser un caractère qcq à la place des balises <liste>
  # If there is no yield given, the field is displayed as is, with 'to_s' method.
  # Call it like : 
  #   <%= show_liste(@contribution.binaires, 'contribution') {|e| e.nom} %>
  def show_liste(elements, nom = '', options = {}) 

    size = elements.size
    return "<u><b>Aucun(e) #{nom}</b></u><br />" unless size > 0
    if session[:user].nil? and options[:public].nil?
      return "<u><b>#{pluralize(size, nom.capitalize)} à ce jour</b></u><br />" 
    end
    result = ''
    unless options[:title]==false or options[:no_title]
      result << "<b>#{pluralize(size, nom.capitalize)} : </b><br/>"
    end

    # Define a default bloc unless bloc is given
    # call "yield_or_default .call(e)" in spite of "yield(e)"
    # TODO : use it when yarv virtual machine is ready
    unless block_given?
      result << '<ul>' 
      elements.each { |e| 
        result << '<li>' << e << '</li>' unless e.nil?
      }
      result << '</ul>'
      return result
    end
    # c'est lent mais c'est tellement beau ruby :
    # yield_or_default = proc {|e| (block_given? ? yield(e) : e) }

    if options[:puce]
      puce = " #{options[:puce]} "
      elements.each { |e| 
        elt = yield(e)
        result << puce << elt << '<br/>' unless elt.nil?
      }
    else
      result << '<ul>' 
      elements.each { |e| 
        elt = yield(e)
        result << '<li>' << elt << '</li>' unless elt.nil?
      }
      result << '</ul>'
    end
    result
  end

  def public_show_liste(elements, nom = '', options = {}, &functor) 
    options[:public] = true
    show_liste(elements, nom, options, &functor)
  end

  # Call it like :
  # <% titres = ['Fichier', 'Taille', 'Auteur', 'Maj'] %>
  # <%= show_table(@documents, Document, titres) { |e| "<td>#{e.nom}</td>" } %>
  # N'oubliez pas d'utiliser les <td></td>
  # 3 options
  #   :total > désactive le décompte total si positionné à false
  #   :content_columns > active l'affichage des content_columns si positionné à true
  #   :add_lines > affiche à la fin le tableau de lignes passé [[line1],[line2]]
  # TODO : intégrer width et style dans une seule option
  def show_table(elements, ar, titres, options = {})
    return "<br/><p>Aucun #{ar.table_name.singularize} à ce jour</p>" unless elements and elements.size > 0
    width = ( options[:width] ? "width=#{options[:width]}" : "" )
    result = "<table #{width} class=\"show_table\">"

    if titres.size > 0
      result << '<tr>'
      if (options[:content_columns])
        ar.content_columns.each{|c| result <<  "<th>#{c.human_name}</th>"}
      end
      #On doit mettre nowrap="nowrap" pour que ça soit valide XHTML
      titres.each {|t| result << "<th nowrap=\"nowrap\">#{t}</th>" }
      result << '</tr>'
    end

    elements.each_index { |i|
      result << "<tr class=\"#{cycle('pair', 'impair')}\">"
      if (options[:content_columns])
        ar.content_columns.each {|column|
          result << "<td>#{elements[i].send(column.name)}</td>"
        }
      end
      result << yield(elements[i])
      result << '</tr>'
    }

    if (options[:add_lines])
      options[:add_lines].each {|line|
        result << "<tr>"
        line.each {|cell|
          result << "<td>#{cell}</td>"
        }
        result << "</tr>"
      }
    end
    result << '</table><br/>'
  end

  # show_total(elements.size, ar, options)
  # Valid options
  # :total => false (affiche la taille des éléments et pas un ActiveRecord.count)
  def show_total(size, ar, options = {})
    if options[:total] == false
      result = "<p><b>#{size}</b> "
    else
      result = "<p><b>#{ar.count}</b> "
    end
    result << (size==1? ar.table_name.singularize : ar.table_name.pluralize)
    result << '</p>'
  end


  ### TIME ######################################################################

  #affiche le nombre de jours ou un "Sans objet"
  def display_jours(temps)
    return temps unless temps.is_a? Numeric
    case temps
    when -1 then "Sans objet"
    when 1 then "1 jour ouvré"
    when 0..1 then temps.to_s + " jour ouvré"
    else temps.to_s + " jours ouvrés"
    end
  end

  def display_seconds(temps)
    return temps #unless temps.is_a? Numeric
    # temps==-1 ? "sans engagement" : distance_of_time_in_french_words(temps) + " "
  end

  # conversion secondes en jours
  def sec2jour(seconds)
    ((seconds.abs)/(60*60*24)).round
  end
  # conversion secondes en minutes
  def sec2min(seconds)
    ((seconds.abs)/60).round
  end


  ### MENU #####################################################################

  # Display a simple menu (without submenu) from an array
  # a field may be add in the array, to select a ticket
  # Options
  #  * :form include all in a form_tag 
  #  * :add_class specifie a class to overide .simple_menu style
  def build_simple_menu(menu, options={})
    return unless menu.is_a? Array 
    menu.compact!
    class_name = options[:class] ||= 'simple_menu'
    out = ''
    out << '<div class="'+ class_name +'">'
    out << form_tag(:controller => 'demandes', :action => 'list') if options[:form]
    out << ' <ul>'
    menu.each { |e| out << "<li>#{e}</li>" } 
    out << ' </ul>'
    out << end_form_tag if options[:form]
    out << '</div>'
  end

  # Build a menu from a hash of 2 arrays : titles and links
  # TODO : move js to public/js folder
  # Need common.css #menu part and following js :  
  # Call it like : 
  # <% menu = {} %>
  #   <% menu[:titles], menu[:links] = [], [] %>
  #   <% menu[:titles] << 'Un groupe de lien' %>
  #   <% menu[:links] << [ link_to('Par ici'), link_to('Par là') ] %>
  # <%= build_menu(menu) %>
  def build_menu(menu, options = {})
    return unless menu[:titles].is_a? Array 
    return unless menu[:titles].size == menu[:links].size
    prefix = 'smenu'
    out = ''
    out << "<script type=\"text/javascript\"><!--
    window.onload=montre;
    function montre(id) {
      var d = document.getElementById(id);
      for (var i = 0; i<=10; i++) {
        if (document.getElementById('smenu'+i)) {
            document.getElementById('smenu'+i).style.display='none';
        }
      }
      if (d) {d.style.display='block';}
    }
    //--></script>"
    out << '<div id="menu" onmouseout="javascript:montre(\'\');">'
    menu[:titles].each_index {|i| 
      id = prefix + i.to_s
      out << "<div class=\"liste_menu\" onmouseover=\"javascript:montre('#{id}');\">"
      out <<   show_liste_menu(id, menu[:links][i], menu[:titles][i])
      out << '</div>'
    } 
    out << '</div>'
  end

  # Display an menu item : a title + a link list
  # Called from build_menu
  def show_liste_menu(id, elements, titre, options = {})
    elements.compact!
    size = elements.size
    return '' unless titre.is_a? String
    result = ''
    result << "<div class=\"liste_title\">#{titre.humanize}</div>"
    return result unless size > 0 #and options[:sublink]
    result << "  <div class=\"liste_items\" id=\"#{id}\" >"
    result << '    <ul>'
    elements.each { |e| result << "<li>#{e}</li>" }
    result << '    </ul>'
    result << '  </div>'
  end


  ### INFORMATIONS #########################################################

  def show_notice
      "<div id=\"information_notice\" class=\"information notice\">
         <div class=\"close_information\" onclick=\"Element.hide('information_notice')\">" + 
         image_delete + "</div>
         <p>" + flash[:notice] + "</p>  
       </div>"
  end

  def show_warn
      "<div id=\"information_error\" class=\"information error\">
         <div class=\"close_information\" onclick=\"Element.hide('information_error')\">" + 
         image_delete + "</div>
         <h2>Une erreur s&#146;est produite</h2>
         <ul><li>" + flash[:warn] + "</li></ul>
       </div>"
  end

end
