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

  # d�lai (en secondes) entre la d�claration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2jours(delai)
  def delai
    (cloture - created_on)
  end
  def delai_to_s
    if reverse : "#{time_in_french_words(delai)}"
    elsif clos && !accepte : "Sans objet"
    else "..."
    end 
  end

  # conditions de mise � jour d'un reversement
  # + "non clos" ET (updated_on > 1 mois)
  # + OU "� reverser"
  def todo(max_jours)
    # TODO : v�rifier max_jours is integer
    age = ((Time.now - updated_on)/(60*60*24)).round
    if !clos && age > max_jours.to_i
      # non clos && non maj
      return "mettre-�-jour" 
    elsif etatreversement == 0
      # non initialis�
      return "reverser"
    else 
      # rien � faire
      return false
    end
  end

  # bilan du workflow "etatreversement" et du booleen "accepte"
  def etat
    out = etatreversement.nom
    case etatreversement.id
     when 1..3 then out << " "
     when 4    then out << " : <b>#{( accepte ? "accept�" : "refus�" )}</b>"
     else           out << " (?)"
    end
    out
  end

  # retourne true si l'�tat du reversement est final
  def clos
    etatreversement.id==4 
  end

  # retourne true si le reversement est clos et qu'il a �t� accept�
  def reverse
    clos && accepte
  end

end
