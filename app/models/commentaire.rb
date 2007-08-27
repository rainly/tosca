#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Commentaire < ActiveRecord::Base
  belongs_to :demande
  belongs_to :identifiant
  belongs_to :piecejointe
  belongs_to :statut
  belongs_to :severite
  belongs_to :ingenieur

  validates_length_of :corps, :minimum => 5,
    :warn => _('You must have a comment with at least 5 characters')
  validate do |record|
    if record.demande.nil?
      record.errors.add _('You must indicate a valid request')
    end
  end

  # On détruit l'éventuelle pièce jointe
  # le belongs_to ne permet pas d'appeler :dependent :'(

  # permet de récuperer l'état du commentaire en texte
  # le booléen correspondant est :  prive = true || false
  def etat
    ( prive ? _("private") : _("public") )
  end

  private
  # We destroy attachment if appropriate
  # belongs_to don't allow us to call :dependent :'(
  before_destroy :delete_pj
  def delete_pj
    self.piecejointe.destroy unless self.piecejointe.nil?
  end

  # update request attributes, when creating a comment
  after_create :update_demande
  def update_demande
    fields = %w(statut_id ingenieur_id severite_id)
    modified = false

    # don't update all attributes if we are on the first comment
    if self.demande.first_comment_id != self.id
      #On met à jour les champs demandeO
      fields.each do |attr|
        #On ne met à jour que si ça a changé
        if self[attr] and self.demande[attr] != self[attr]
          self.demande[attr] = self[attr]
          modified = true
        end
      end
      self.demande.save if modified
    end
  end

  # update description only if it's the first comment
  after_update :update_description
  def update_description
    if self.demande.first_comment_id == self.id
      if self.demande.description != self.corps
        self.demande.update_attribute(:description, self.corps)
      end
    end
  end

end
