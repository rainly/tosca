#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Photo < ActiveRecord::Base
  has_many :clients
  has_many :identifiants
  file_column :image, :magick => { 
    :versions => { "thumb" => "150x50", "medium" => "640x480>" }
  }
end
