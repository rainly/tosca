#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Urlreversement < ActiveRecord::Base
  belongs_to :contribution

  validates_presence_of :url
  validates_presence_of :contribution
  
end
