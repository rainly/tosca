#####################################################
# Copyright Linagora SA 2006 - Tous droits réservés.#
#####################################################
# Include your application configuration below
ActionMailer::Base.smtp_settings = {
  :address  => "mail.linagora.com",
  :port  => 25, 
  :domain  => 'linagora.com'

  #:user_name  => "",
  #:password  => "",
#  :authentication  => :login
} 
ActionMailer::Base.default_charset = "UTF-8"

ActionMailer::Base::MAIL_TEAM = "team@08000linux.com"
ActionMailer::Base::MAIL_TOSCA = "lstm-devel@08000linux.com"