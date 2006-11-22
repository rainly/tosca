#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Statut < ActiveRecord::Base
  has_many :demandes
#########################
# Pour m�moire :        #
#1 	Enregistr�e     #
#2 	Prise en compte #
#3 	Suspendue       #
#4 	Analys�e        #
#5 	Contourn�e      #
#6 	Corrig�e        #
#7 	Cl�tur�e        #
#8       Annul�e        #
#########################

  def possible
    search = case id
             when 1 then "id IN (2)" 
             when 2 then "id IN (4,3,8)"
             when 3 then "id IN (2,5,6)"
             when 4 then "id IN (3)"
             when 5 then "id IN (3)"
             when 6 then "id IN (7)"
             when 7 then "id IN (2)"
             when 8 then "id IN (2)"
             end 
    Statut.find(:all, :conditions => search)
  end

end
