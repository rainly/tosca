#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
class Ingenieur < ActiveRecord::Base
  acts_as_reportable
  belongs_to :user, :dependent => :destroy
  has_many :knowledges, :order => 'knowledges.level DESC'
  has_many :demandes
  has_many :phonecalls


  INCLUDE = [:user]

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
        c.name =~ /(_id|_on|_count|chef_de_projet|expert_ossa)$/ || c.name == inheritance_column }
  end

  def self.find_select_by_contrat_id(contrat_id)
    conditions = [ 'cu.contrat_id = ?', contrat_id ]
    joins = 'INNER JOIN contrats_users cu ON cu.user_id=users.id'
    options = {:find => {:conditions => conditions, :joins => joins}}
    Ingenieur.send(:with_scope, options) do
      Ingenieur.find_select(User::SELECT_OPTIONS)
    end
  end

  def self.find_ossa(*args)
    conditions = 'ingenieurs.expert_ossa = 1'
    Ingenieur.send(:with_scope, {:find => {:conditions => conditions }}) {
      Ingenieur.find(*args)
    }
  end

  def self.find_presta(*args)
    conditions = ['ingenieurs.expert_ossa = ?', 0 ]
    Ingenieur.send(:with_scope, {:find => {:conditions => conditions }}) {
      Ingenieur.find(*args)
    }
  end

  # Don't forget to make an :include => [:user] if you
  # use this small wrapper.
  def name
    user.name
  end
end
