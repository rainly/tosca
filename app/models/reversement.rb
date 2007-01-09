#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Reversement < ActiveRecord::Base
  # le :include sert � specifier quel 
  # beneficiaire pourra consulter le reversement
  belongs_to :correctif
  belongs_to :interaction
  belongs_to :etatreversement

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary || 
        c.name =~ /(_id|_on)$/ || c.name == inheritance_column }     
  end

  # date de cloture formatt�e
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def cloture_formatted
      d = @attributes['cloture']
      "#{d[8,2]}.#{d[5,2]}.#{d[0,4]} � #{d[11,2]}h#{d[14,2]}"
  end

  # d�lai en jour
  def delai
    (cloture - created_on)
  end

end
