#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :identifiant, :counter_cache => true
  belongs_to :piecejointe
  belongs_to :statut
  
  validates_length_of :corps, :minimum => 5, :warn => "Vous devez mettre un commentaire d'au moins 5 caract�res"

  # On d�truit l'�ventuelle pi�ce jointe
  # le belongs_to ne permet pas d'appeler :dependent :'(


  # permet de r�cuperer l'�tat du commentaire en texte
  # le bool�en correspondant est :  prive = true || false
  def etat
    ( prive ? "priv�" : "public" )
  end


  before_destroy :delete_pj

  private
  def delete_pj
    self.piecejointe.destroy if self.piecejointe_id
  end

end
