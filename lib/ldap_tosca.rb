# Ldap authentication is active only if fill in the configuration file.
module LdapTosca

  CONFIGURATION_FILE = "#{RAILS_ROOT}/config/ldap.yml"

  def self.included(base)
    super(base)
    if Setting.ldap_enabled?
      require 'ldap'
      base.extend(LdapToscaClassMethods)
    end
  end

  module LdapToscaClassMethods

    def self.extended(subclass)
      super(subclass)
      class << subclass
        alias_method :authenticate_without_ldap, :authenticate
        alias_method :authenticate, :authenticate_with_ldap
      end
    end

    READ_ATTRIBUTES = %w(uid cn mail mobile modifyTimestamp)

    # Authentificate the user
    # Can throw an Exception if LDAP is unreachable, via connect method
    def authentificate_user(login, password)
      user = nil
      ldap_conn = self.connect(login, password) do |conn|
        res = conn.search2(Setting.ldap_basedn,
                           LDAP::LDAP_SCOPE_ONELEVEL,
                           Setting.ldap_filter % login,
                           READ_ATTRIBUTES)
        user = res.first unless res.empty?
      end
      user
    end

    TS_FORMAT = 'a4a2a2a2a2a2'

    # Key method, coming from User AR model
    def authenticate_with_ldap(login, pass)
      user = User.first(:conditions => { :login => login })
      # customer authentication is not on ldap
      return authenticate_without_ldap(login, pass) if user and user.recipient?

      ldap_user = nil
      begin
        ldap_user = self.authentificate_user(login, pass)
      rescue
        # fallback when ldap is down or not reachable
        return authenticate_without_ldap(login, pass)
      end

      # expert access can be disabled directly in ldap
      return nil unless check_access(user, ldap_user)
      # fallback when ldap search failed (invalid dn, for instance)
      return authenticate_without_ldap(login, pass) unless ldap_user

      ts = Time.utc(*ldap_user['modifyTimestamp'].
                first.unpack(TS_FORMAT)).localtime
      if user.nil? or user.updated_on.nil? or ts > user.updated_on
        update_account_from_ldap(user, ldap_user, pass)
      end
      user
    end

    protected

    def update_account_from_ldap(user, ldap_user, password)
      user ||= User.new(:client_id => nil, :role_id => 3)
      user.name = ldap_user['cn'].first
      user.login = ldap_user['uid'].first
      user.email = ldap_user['mail'].first
      user.pwd = password
      user.pwd_confirmation = password
      user.phone = ldap_user['mobile'].first
      user.ldap = true
      user.save!
    end

    # this method checks and deactivates accounts
    # disabled on ldap
    def check_access(user, ldap_user)
      return false if user and user.inactive?
      if ldap_user.nil? and user and user.ldap?
        # Account deactivated on ldap but not on Tosca
        user.update_attribute(:inactive => true)
        false
      else
        true
      end
    end

    #Connect to the LDAP and handle errors
    #Takes a bloc which yields the connection
    #Return nil if there was a problem
    def connect(login, pwd)
      ldap_conn = LDAP::Conn.new(Setting.ldap_host, Setting.ldap_port.to_i)
      ldap_conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, Setting.ldap_protocol.to_i)
      begin
        ldap_conn.start_tls.nil?
      rescue LDAP::Error => e
        logger.error "LDAP connection problem : #{e}"
        raise "Connection problem"
      end
      begin
        ldap_conn.bind(Setting.ldap_binddn % login, pwd)
        yield(ldap_conn) if ldap_conn.bound?
        ldap_conn.unbind
      rescue LDAP::ResultError
        ldap_conn.unbind if ldap_conn.bound?
        ldap_conn = nil
      end
      ldap_conn
    end
  end
end
