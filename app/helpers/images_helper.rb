#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module ImagesHelper

  # TODO : utiliser image_options (cf image_delete pour exemple)
  # We cannot cache a parametered image

  # por éviter la réaffection de desc à chaque coup
  def image_options(desc = '')
    { :border => 0, :alt => desc, :title => desc }
  end

  # Database manipulation

  @@create = nil
  def image_create(message)
    desc = "Déposer #{message}"
    @@create ||= image_tag("create_icon.png", :size => "16x16",
                           :border => 0, :alt => desc, :title => desc )
  end

  @@view = nil
  def image_view
    desc = 'Consulter'
    @@view ||= image_tag('icons/b_view.png', :size => '15x15',
                         :border => 0, :alt => desc, :title => desc )
  end

  @@edit = nil
  def image_edit
    desc = 'Modifier'
    @@edit ||= image_tag('edit_icon.gif', :size => '15x15',
                         :border => 0, :alt => desc, :title => desc )
  end

  @@delete = nil
  def image_delete
    @delete ||= image_tag('delete_icon.gif', image_options('Supprimer')\
                          .update(:size => '15x17'))
  end

  # Navigation

  @@back = nil
  def image_back
    desc = 'Retour'
    @@back ||= image_tag("back_icon.png", :size => "23x23",
                         :border => 0, :alt => desc, :title => desc, 
                         :align => 'bottom' )
  end

  @@first_page = nil
  def image_first_page
    desc = 'Première page'
    @@first_page ||= image_tag("first_page.png", :size => "14x14", 
                         :border => 0, :alt => desc, :title => desc )
  end

  @@previous_page = nil
  def image_previous_page
    desc = 'Page précédente'
    @@previous_page ||= image_tag("previous_page.png", :size => "14x14",
                                :border => 0, :alt => desc, :title => desc )
  end


  def image_next_remote_page
    image_tag("next_page.png", :size => "14x14",
              :border => 0, :alt => 'Page suivante', 
              :title => 'Page suivante', :onclick => 
              " alert('ca y est');")
  end

  @@next_page = nil
  def image_next_page
    @@next_page ||= image_tag("next_page.png", :size => "14x14",
                              :border => 0, :alt => 'Page suivante', 
                              :title => 'Page suivante' )
  end

  @@last_page = nil
  def image_last_page
    desc = 'Dernière page'
    @@last_page ||= image_tag("last_page.png", :size => "14x14",
                                :border => 0, :alt => desc, :title => desc )
  end

  @@folder = nil
  def image_folder
    desc = 'Fichier'
    @@folder ||= image_tag('folder_icon.gif', :size => '16x16',
                           :border => 0, :alt => desc, :title => desc,
                           :align => 'bottom')
  end

  # Security

  @@public = nil
  def image_public
    desc = 'Rendre public'
    @@public ||= image_tag('public_icon.png', :size => '17x16',
                           :border => 0, :alt => desc, :title => desc )
  end

  @@private = nil
  def image_private
    desc = 'Rendre privé'
    @@private ||= image_tag('private_icon.png', :size => '12x14',
                            :border => 0, :alt => desc, :title => desc )
  end

  # Logos

  @@logo_08000 = nil
  def logo_08000
    desc = '08000 LINUX'
    @@logo_08000 ||= image_tag('logo_08000.gif', :alt => desc, :title => desc)
  end

  @@logo_lstm = nil
  def logo_lstm
    desc = 'Accueil'
    @@logo_lstm ||= image_tag('logo_lstm.gif', :alt => desc, :title => desc)
  end

  @@logo_ruby = nil
  def logo_ruby
    desc = 'OSSA on rails'
    @@logo_ruby ||= image_tag('ruby.png', :size => '15x15',
                              :border => 0, :alt => desc, :title => desc)
  end

  @@image_favicon = nil 
  def image_favicon
    @@image_favicon ||= image_path("favicon.ico")
  end

  # Other

  @@spinner = nil
  def image_spinner
    @@spinner ||= image_tag('spinner.gif', :border=> 0, :id => 'spinner',
                            :style=> 'display: none;')
  end

end
