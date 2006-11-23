#####################################################
# Copyright Linagora SA 2006 - Tous droits r�serv�s.#
#####################################################
*# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'overrides'
require 'utils'
require 'config'
# require 'gruff'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

#TimeZone fran�aise, n�cessaire sur ces *hum* de debian
ENV['TZ'] = 'Europe/Paris'

# Add new inflection rules using the following format 
# (all these examples are active by default):
Inflector.inflections do |inflect|
  inflect.plural /^(ox)$/i, '\1en'
  inflect.singular /^(ox)en/i, '\1'
  inflect.irregular 'person', 'people'
  inflect.irregular 'typeanomalie', 'typeanomalies'
  inflect.irregular 'jourferie', 'jourferies'
  inflect.uncountable %w( fish sheep )
end


# Meta data ici :
# ajouter par Lstm
module Metadata

  # application
  NOM_COURT_APPLICATION = "LSTM"
  NOM_LONG_APPLICATION = "Linagora Software Tracker Manager"
  COPYRIGHT_APPLICATION = "Copyright Linagora SA 2006 - Tous droits r�serv�s."

  # service
  NOM_COURT_SERVICE = "OSSA"
  NOM_LONG_SERVICE = "Open Source Software Assurance"
  NOM_ENTREPRISE = "Linagora"

  # contacts
  PREFIXE_TELEPHONE = "08000"
  CODE_TELEPHONE = "54689"
  TEXTE_TELEPHONE = "LINUX"
  SITE_INTERNET = "08000LINUX.com"

end



# R�d�finit globalement en fran�ais les messages d'erreur
ActiveRecord::Errors.default_error_messages = {
  :inclusion => "n'est pas inclus dans la liste",
  :exclusion => "est r�serv�",
  :invalid => "est invalide",
  :confirmation => "ne correspond pas � la confirmation",
  :accepted => "doit �tre accept�",
  :empty => "ne peut �tre vide",
  :blank => "ne peut �tre blanc",
  :too_long => "est trop long (max. %d caract�re(s))",
  :too_short => "est trop court (min %d caract�re(s))",
  :wrong_length => "a une longueur incorrecte (doit �tre de %d caract�re(s))",
  :taken => "est d�j� utilis�",
  :not_a_number => "n'est pas une valeur num�rique"
}

# R�d�finit globalement en fran�ais les titres et textes de la bo�tes d'erreur
module ActionView::Helpers::ActiveRecordHelper
  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      if object.errors.count==1 then
        content_tag("div",
                    content_tag(
                                options[:header_tag] || "h2",
                                "Une erreur a bloqu� l'enregistrement de #{object_name.to_s.gsub("_", " ")}"
                                ) +
                                   content_tag("p", "Corriger l'�l�ment suivant pour poursuivre :") +
                                   content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
                    "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
                    )
      else
        content_tag("div",
                    content_tag(
                                options[:header_tag] || "h2",
                                "#{object.errors.count} erreurs ont bloqu� l'enregistrement de #{object_name.to_s.gsub("_", " ")}"
                                ) +
                                   content_tag("p", "Corriger les �l�ments suivants pour poursuivre :") +
                                   content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }),
                    "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation"
                    )
      end
    end
  end
end

#red�finit l'affichage des urls _uniquement_ si l'utilisateur en a le droit
module ActionView::Helpers::UrlHelper

 def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
   if html_options
     html_options = html_options.stringify_keys
     convert_options_to_javascript!(html_options)
     tag_options = tag_options(html_options)
   else
     tag_options = nil
   end
   url = options.is_a?(String) ? options : self.url_for(options, *parameters_for_method_reference)
   required_perm = "%s/%s" % [ options[:controller] || @controller.controller_name, 
     options[:action] || @controller.action_name ]
   if @session[:user] and @session[:user].authorized? required_perm then
     "<a href=\"#{url}\"#{tag_options}>#{name || url}</a>"
   else
     nil
   end
 end
end




