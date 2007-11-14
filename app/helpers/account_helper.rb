#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
module AccountHelper

  def avatar(recipient, engineer)
    if recipient
      logo_client(recipient.client)
    else
      if engineer.image_id.blank?
        StaticImage::logo_08000
      else
        image_tag(url_for_file_column(engineer.image, 'image', 'thumb'))
      end
    end
  end

  def get_title(user)
    result = ''
    if session[:user].id == @user.id
      result << _('My account')
    else
      result << _('Account of %s') % @user.name 
    end
    result << " (#{_('User|Inactive')})" if @user.inactive
    result
  end

end
