#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
#
# This helpers is here to put links helper not really
# related to any model or controller.
#
# They help to generate link with image, for instance,
# or link to files.
#
# It contains also general links in the header/footer part
#
module LinksHelper

  # this contains the hash for escaping hover effect for images
  # this is put in every links with image
  NO_HOVER = { :class => 'no_hover' }

  # Call it like this : link_to_file(document, 'fichier', 'nomfichier')
  # don't forget to update his public alter ego just below
  # DO NOT EVER CALL this method with 'public' parameter set
  # to true, use <b>public_link_to_file</b> instead
  #
  def link_to_file(record, file, options={}, public = false)
    return '-' unless record
    filepath = record.send(file)
    unless filepath.blank? or not File.exist?(filepath)
      filename = filepath[/[._ \-a-zA-Z0-9]*$/]
      if options[:image]
        show = image_patch and html_options = {:class => 'no_hover'}
      else
        show = filename and html_options = {}
      end
      url = url_for_file_column(record, file, :absolute => true)
      if public
        public_link_to show, url, html_options
      else
        link_to show, url, html_options
      end
    end
  end

  def public_link_to_file(record, file, options={})
    link_to_file(record, file, options, true)
  end

  @@delete_options = { :class => 'nobackground', :method => :delete }
  def delete_options(objet_name)
    @@delete_options.update(:confirm =>
        _('Do you really want to delete %s') % objet_name)
  end

  def edit_options
    LinksHelper::NO_HOVER
  end

  ### Header ###
  # TODO : put all those methods into another module
  # and merge it dynamically in this module
  @@home = nil
  def public_link_to_home
    @@home ||= public_link_to(_('Accueil'), bienvenue_path)
  end

  @@requests = nil
  def link_to_requests
    @@requests ||= link_to(_('Demandes'), demandes_path, :title =>
                           _('Consulter vos demandes'))
  end

  @@softwares = nil
  def public_link_to_softwares
    @@softwares ||= public_link_to(_('Logiciels'), logiciels_path, :title =>
                                   _('Consulter les logiciels'))
  end

  @@contributions = nil
  def public_link_to_contributions
    @@contributions ||= public_link_to(_('Contributions'), contributions_path,
       :title => _('Access to the list of contributions.'))
  end

  @@administration = nil
  def link_to_admin
    @@administration ||= link_to(_('Administration'), admin_bienvenue_path,
                           :title => _('Administration interface'))
  end

  # About page
  @@about = nil
  def public_link_to_about()
    @@about ||= public_link_to('?', about_bienvenue_path,
       :title => _("About %s") % Metadata::NOM_COURT_APPLICATION)
  end


end
