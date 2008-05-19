#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
require 'digest/sha1'
require 'ruport'

class User < ActiveRecord::Base
  # Small utils for inactive & password, located in /lib/*.rb
  include InactiveRecord
  include PasswordGenerator

  acts_as_reportable
  belongs_to :image
  has_many :piecejointes
  belongs_to :role
  has_many :documents
  has_many :commentaires

  has_one :ingenieur, :dependent => :destroy
  has_one :beneficiaire, :dependent => :destroy

  has_and_belongs_to_many :contrats

  validates_length_of :login, :within => 3..20
  validates_length_of :password, :within => 5..40
  validates_presence_of :login, :password, :role, :email, :name, :contrats
  validates_uniqueness_of :login

  attr_accessor :pwd_confirmation

  N_('User|Pwd')
  N_('User|Pwd confirmation')


  #Preferences
  preference :digest_daily, :default => false
  preference :digest_weekly, :default => false
  preference :digest_monthly, :default => false

  def pwd
    @pwd
  end

  def pwd=(pass)
    @pwd = pass
    return if pass.blank? or pass.length < 5 or pass.length > 40
    self.password = User.sha1(pass)
  end

  def manager?
    role_id <= 2
  end

  # TODO : this formatting method has to be in an helper, a lib or a plugin.
  # /!\ but NOT here /!\
  before_save do |record|
    ### NUMBERS #########################################################
    number = record.phone.to_s
    number.upcase!
    if number =~ /\d{10}/ #0140506070
      number.gsub!(/(\d\d)/, '\1.').chop!
    elsif number =~ /\d\d(\D\d\d){4}/ #01.40_50f60$70
      number.gsub!(/\D/, ".")
    end
    record.phone = number
    # false will invalidate the save
    true
  end


  # Eck ... We must add message manually in order to
  # not have the "pwd" prefix ... TODO : find a pretty way ?
  # TODO : check if gettext is an answer ?
  def validate
    errors.add(:pwd, _("Password missing")) if password.blank?
    if pwd != pwd_confirmation
      errors.add(:pwd_confirmation, _('Password is different from its confirmation'))
    end
    unless pwd.blank?
      if pwd.length > 40
        errors.add(:pwd, _('Your password is too long (max. 20)'))
      elsif pwd.length < 5
        errors.add(:pwd, _('Your password is too short (min. 5)'))
      end
    end
    if pwd.blank? and self.password.blank?
      errors.add(:pwd, _('You must have specify a password.'))
    end
  end

  # This reduced the scope of User to allowed contracts of current user
  def self.get_scope(contrat_ids)
    { :find => { :conditions =>
          [ 'contrats_users.contrat_id IN (?) ', contrat_ids ], :joins =>
        'INNER JOIN contrats_users ON contrats_users.user_id=users.id ' } }
  end


  # Associate current User to a recipient profile
  def associate_recipient(client_id)
    client = nil
    client = Client.find(client_id.to_i) unless client_id.nil?
    self.beneficiaire = Beneficiaire.new(:user => self, :client => client)
    self.client = true
  end

  # Associate current User to an Engineer profile
  def associate_engineer()
    self.ingenieur = Ingenieur.new(:user => self)
    self.client = false
  end

  SELECT_OPTIONS = { :include => [:user], :order =>
    'users.name ASC', :conditions => 'users.inactive = 0' }
  EXPERT_OPTIONS = { :conditions => 'users.client = 0', :order => 'users.name' }

  def self.authenticate(login, pass, crypt = 'false')
    User.with_exclusive_scope() do
      pass = sha1(pass) if crypt == 'false'
      user = User.find(:first, :conditions =>
                              ['login = ? AND password = ?', login, pass])
      return nil if user and user.inactive?
      user
    end
  end

  # Pour la gestion des roles/perms :

  # Return true/false if User is authorized for resource.
  def authorized?(resource)
    match = false

    permission_strings.each do |r|
      if ((r =~ resource) != nil)
        match = true
        break
      end
    end
    return match
  end


  def name
    strike(:name)
  end

  # will always be clean
  def name_clean
    read_attribute(:name)
  end

  # cached, coz' it's used in scopes
  def contrat_ids
    @contrat_ids ||= self.contrats.find(:all, :select => 'id').collect {|c| c.id}
  end

  # cached, coz' it's used in scopes
  def client_ids
    @client_ids ||= self.contrats.find(:all, :select =>
                      'distinct client_id').collect {|c| c.client_id}
  end

  def kind
    (client? ? 'recipient' : 'expert')
  end


  private
  # Load permission strings
  # TODO : cache this method. Since we have few roles, it's possible
  # to use a table or a hash.
  # See app/helpers/static_image/rb#self.severite for a bad sample
  # See http://api.rubyonrails.com/classes/ActiveSupport/CachingTools/HashCaching.html#M000319 for a better way
  # See also http://api.rubyonrails.com/classes/ActiveSupport/CachingTools/HashCaching.html#M000319 for a complete overview
  def permission_strings
    return @permissions if @permissions
    @permissions = self.role.permissions.collect{|p| Regexp.new(p.name) }
    @permissions
  end

  def self.sha1(pass)
    Digest::SHA1.hexdigest("linagora--#{pass}--")
  end

  # specialisation, since an Account can be <inactive>.
  def find_select(options = { })
    find_active4select(options)
  end


  # For Ruport :
  def beneficiaire_client_name
    beneficiaire.client.name if beneficiaire
  end

  def role_name
    role.name if role
  end

end
