#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Changelog < ActiveRecord::Base
  belongs_to :paquet

  def date_modification_formatted
    d = @attributes['date_modification']
    "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} "
  end

end
