#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Logiciel < ActiveRecord::Base

  has_many :classifications
  has_and_belongs_to_many :competences
  has_and_belongs_to_many :projets
  belongs_to :license

  has_many :demandes
  has_many :urllogiciels, :dependent => :destroy
  has_many :paquets, :order => "version DESC", :dependent => :destroy

  has_many :interactions

  validates_presence_of :competences => 
    "Vous devez sp�cifier au moins une competence" 

  def self.list_columns 
    columns.reject { |c| c.primary || 
        c.name =~ /(_id|nom|resume|description|referent)$/ || 
          c.name == inheritance_column } 
  end


  def mes_paquets(beneficiaire)
    if beneficiaire
      paquets.find_all_by_contrat_id( beneficiaire.client.\
                                      contrats.collect{|c| c.id}, 
                                      :order => "version DESC")
    else
      paquets
    end
  end

  def count_mes_paquets(beneficiaire)
    if beneficiaire
      Paquet.count(:all, :conditions => 
                     "contrat_id IN (#{contrats.collect{|c| c.id}.join(',')})")
    else
      Paquet.count(:all, :conditions => "logiciel_id = #{id}")
    end
  end


#  def mes_correctifs(beneficiaire)
#    if beneficiaire
#      result = []
#      correctifs.each do |co|
#        result.concat co.mes_paquets(beneficiaire)
#      end
#      result
#    else
#      correctifs
#    end
#  end


  def to_param
    "#{id}-#{nom.gsub(/[^a-z1-9]+/i, '-')}"
  end

  def to_s
    nom
  end

end
