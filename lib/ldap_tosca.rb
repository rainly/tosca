# Ldap authentication is active only if fill in the configuration file.
module LdapTosca

  CONFIGURATION_FILE = "#{RAILS_ROOT}/config/ldap.yml"

  def self.included(base)
    super(base)
    if Setting.table_exists? and Setting.ldap_enabled?
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
    TS_FORMAT = 'a4a2a2a2a2a2'

    # Key method, coming from User AR model
    def authenticate_with_ldap(login, pass)
      user = User.first(:conditions => { :login => login })
      # customer authentication is not on ldap
      return authenticate_without_ldap(login, pass) if user and user.recipient?

      ldap_conn = self.connect2ldap
      return authenticate_without_ldap(login, pass) unless ldap_conn

      ldap_user = self.search_user(ldap_conn, login)
      return nil unless check_access(user, ldap_user)
      return authenticate_without_ldap(login, pass) unless ldap_user

      ldap_auth = self.authenticate_user(ldap_conn, login, pass)
      return authenticate_without_ldap(login, pass) unless ldap_auth

      ts = Time.utc(*ldap_user['modifyTimestamp'].
                first.unpack(TS_FORMAT)).localtime
      if user.nil? or user.updated_on.nil? or ts > user.updated_on
        self.update_account_from_ldap(user, ldap_user, pass)
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
      user.phone = (ldap_user['mobile'] || ['']).first
      user.ldap = true
      user.save!
    end

    # this method checks and deactivates accounts
    # disabled on ldap
    def check_access(user, ldap_user)
      return false if user and user.inactive?
      if ldap_user.nil? and user and user.ldap?
        # Account deactivated on ldap but not on Tosca
        user.update_attribute(:inactive, true)
        false
      else
        true
      end
    end

    # Connect to the LDAP and handle errors
    # Return nil if there was a problem
    def connect2ldap
      ldap_conn = LDAP::Conn.new(Setting.ldap_host, Setting.ldap_port.to_i)
      ldap_conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, Setting.ldap_protocol.to_i)
      begin
        ldap_conn.start_tls.nil?
      rescue LDAP::Error => e
        logger.error "LDAP connection problem : #{e}"
        ldap_conn = nil
      end
      ldap_conn
    end

    # lookup an user, without credentials
    def search_user(ldap_conn, login)
      res = ldap_conn.search2(Setting.ldap_basedn,
                              LDAP::LDAP_SCOPE_ONELEVEL,
                              Setting.ldap_filter % login,
                              READ_ATTRIBUTES)
      (res.empty? ? nil : res.first)
    end

    # try credential
    def authenticate_user(ldap_conn, login, pwd)
      authentication_success = false
      begin
        ldap_conn.bind(Setting.ldap_binddn % login, pwd)
        authentication_success = true
        ldap_conn.unbind
      rescue LDAP::ResultError
        ldap_conn.unbind if ldap_conn.bound?
      end
      authentication_success
    end

  end
end
