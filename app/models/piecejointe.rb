#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Piecejointe < ActiveRecord::Base
  file_column :file
  has_one :commentaire

  def nom
    return file[/[._ \-a-zA-Z0-9]*$/] if file
  end



end
