class Contribution < ActiveRecord::Base
  acts_as_reportable

  has_one :demande
  has_many :urlreversements

  belongs_to :typecontribution
  belongs_to :etatreversement
  belongs_to :logiciel
  belongs_to :ingenieur

  belongs_to :version

  file_column :patch, :fix_file_extensions => nil

  validates_length_of :name, :within => 3..100
  validates_presence_of :logiciel,
    :warn => _('You have to specify a software.')

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|^patch)$/ || c.name == inheritance_column }
  end

  # TODO : tout le monde doit pouvoir voir toutes les contributions.
  # Ca pose problème avec le scope logiciel ...
  # See ApplicationController#scope
  def self.set_scope(contract_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'versions.contract_id IN (?)', contract_ids ], :include => [:versions] } }
  end

  def to_s
    return name unless patch
    index = patch.rindex('/')+ 1
    patch[index..-1]
  end

  def fragments
    [ %r{contributions/select_(\d*|all)} ]
  end

  def summary
    out = ''
    out << typecontribution.name + _(' on ') if typecontribution
    out << logiciel.name
    out << " #{version}" if version
    out
  end

  def to_param
    "#{id}-#{name.gsub(/[^a-z1-9]+/i, '-')}"
  end

  # date de reversement formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def reverse_le_formatted
    contributed_on = read_attribute(:reverse_le)
    return '' unless contributed_on
    display_time contributed_on
  end

  # date de cloture formattée
  # voir lib/overrides.rb pour les dates auto created _on et updated_on
  def cloture_le_formatted
    closed_on = read_attribute(:cloture_le)
    return '' unless closed_on
    display_time closed_on
  end

  # délai (en secondes) entre la déclaration et l'acceptation
  # delai_to_s (texte)
  # en jours : sec2day(delai)
  def delai
    if cloture_le and reverse_le
      (cloture_le - reverse_le)
    else
      -1
    end
  end

  # conditions de mise à jour d'un reversement
  # + "non clos" ET (updated_on > 1 mois)
  # + OU "à reverser"
  def todo(max_jours)
    return false unless reverse_le
    # TODO : vérifier max_jours is integer
    age = ((Time.now - reverse_le)/(60*60*24)).round
    if !clos && age > max_jours.to_i
      # non clos && non maj
      return "mettre-à-jour"
    elsif !reverse
      # non initialisé
      return "reverser"
    end
      # rien à faire
    return false
  end

  # retourne true si le reversement a commencé
  def reverse
    (reverse_le ? true : false)
  end

  # retourne true si l'état du reversement est final
  # "accepté", "refusé", "ne sera pas reversé"
  def clos
    (cloture_le ? true : false)
  end

  def clos=(fake)
  end
  def reverse=(fake)
  end

  # retourne true si le reversement est accepté
  def accepte
    return false unless etatreversement
    etatreversement_id == 4
  end

  # For Ruport :
  def pname(object)
    (object ? object.name : '-')
  end
  def pname_typecontribution
    pname(typecontribution)
  end
  def pname_logiciel
    pname(logiciel)
  end
  def pname_etatreversement
    pname(etatreversement)
  end
  def clos_enhance
    clos ? cloture_le_formatted : ''
  end
  def delai_in_french_words
    Time.in_words(delai)
  end
  def version_to_s
    affected_version.to_s
  end

end
