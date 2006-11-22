#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :identifiant
  belongs_to :piecejointe, :dependent => :destroy
  belongs_to :statut
  
  validates_length_of :corps, :minimum => 5, :warn => "Vous devez mettre un commentaire d'au moins 5 caract�res"

  # permet de r�cuperer l'�tat du commentaire en texte
  # le bool�en correspondant est :  prive = true || false
  def etat
    ( prive ? "priv�" : "public" )
  end

end
