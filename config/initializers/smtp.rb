if Setting.table_exists? # allows to create database
  ActionMailer::Base.smtp_settings = {
    :address  => Setting.email_server,
    :port  => Setting.email_port,
    :domain  => Setting.email_domain
  }
  ActionMailer::Base.default_charset = Setting.email_charset
end
