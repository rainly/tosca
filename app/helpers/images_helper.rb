
#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################

module ImagesHelper

  def image_create(message)
    desc = _("Add %s") % message
    image_tag("create_icon.png", StaticImage::options(desc, '16x16'))
  end

  private

  # por éviter la réaffection de desc à chaque coup
  def my_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  def logo_client(client)
    version = (client.inactive? ? 'inactive_thumb' : 'thumb')
    logo_client(client, version)
  end

  def logo_client_small(client)
    return logo_client(client, "small")
  end

  #Call if like logo_client(Client.find(1), "small')
  def logo_client(client, size)
    return '' if client.nil? or client.image.blank? or size.nil?
    image_tag(url_for_file_column(client.image, 'image', size),
              image_options(client.name_clean))
  end

  def software_logo(software)
    return '' if software.nil? or software.image.blank?
    image_tag(url_for_file_column(software.image, 'image', 'thumb'))
  end

  #TODO Merger avec StaticImage
  def image_options(desc = '', size = nil )
    options = { :alt => desc, :title => desc, :class => 'no_hover' }
    options[:size] = size if size
    options
  end

  # See usage in reporting_helper#progress_bar
  # It show a percentage of progression.
  def image_percent(percent, color)
    desc = _('progress bar')
    style = "background-position: #{percent}px; background-color: #{color};"
    options = { :alt => desc, :title => desc, :style => style,
      :class => 'percentImage' }
    image_tag('percentimage.png', options)
  end

  # call it like :
  # <%= link_to_new_paquet(@logiciel) %>
  def link_to_new_client_logo()
    options = LinksHelper::NO_HOVER.dup.update(:target => '_blank')
    link_to(image_create(_('a logo')), new_img_path, options)
  end


end
