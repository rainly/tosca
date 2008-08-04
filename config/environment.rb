# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1' unless defined? RAILS_GEM_VERSION
$KCODE='u'
require 'jcode'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Needed for checking missing files
require 'utils'

path = File.join RAILS_ROOT, 'config', 'database.yml'
Utils.check_files(path, 'Your database is not configured')
path = File.join RAILS_ROOT, 'lib', 'config.rb'
Utils.check_files(path, 'Your mail server is not configured')

cache_path = File.join RAILS_ROOT, 'tmp', 'cache'
page_cache_path = File.join RAILS_ROOT, 'public', 'cache'

# Used to have extension
# See http://github.com/pivotal/desert/tree/master for more info
require 'desert'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  config.frameworks -= [ :action_web_service ] # , :action_mailer ]

  # Extension are like rails plugins
  config.plugin_paths += %W( #{RAILS_ROOT}/vendor/extensions )

  # Sweepers are used to cleanup cache nicely
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Distinguish cache from normal pages
  config.action_controller.page_cache_directory = page_cache_path

  ### External libs ###
  # Used to i18n and l10n
  config.gem 'gettext', :version => '1.91.0'

  # Used to generate graphs of activity report & resize some pictures
  # We keep 1.15.10 version, coz debian makes an old & staging distribution
  config.gem 'rmagick', :lib => 'RMagick', :version => '1.15.10'
  # Used to load the extension mechanism
  config.gem 'desert', :version => '0.2.1'

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the file store with a custom storage path (if the directory doesn’t already exist it will be created)
  config.cache_store = :file_store, cache_path

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

# MLO : sql session store, 1.5x times faster than Active record store
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.
  update(:database_manager => SqlSessionStore)
SqlSessionStore.session_class = MysqlSession

# MLO : Type of cache. See http://api.rubyonrails.org/classes/ActionController/Caching.html
ActionController::Base.cache_store = :file_store, cache_path


# MLO : session duration is one month,
CGI::Session.expire_after 1.month

# MLO : It's faster to use X-Send-File module of Apache
XSendFile::Plugin.replace_send_file! if RAILS_ENV == 'production'

# Config file, mainly use for mail server
require 'config'

# Extensions to String Class
# TODO : make an extension loader, which loads automatically all _extensions.rb
# files
require 'string_extensions'

# Internal libs, located in lib/
require 'overrides'


# Check and create used dirs, which are not on the SCM
log_path = File.join RAILS_ROOT, 'log'
paths = [ log_path, page_cache_path, cache_path ]
paths.each { |path| FileUtils.mkdir_p(path) unless File.exists? path }

# French TimeZone, mandatory coz' of debian nerds :/
ENV['TZ'] = 'Europe/Paris'

# Mime type needed for ods export with Ruport lib
# See app/controller/export_controller.rb
Mime::Type.register "application/vnd.oasis.opendocument.spreadsheet", :ods

# Neeeded for making password, in other things
srand

# Boot Check
path = File.join RAILS_ROOT, "locale", "fr", "LC_MESSAGES", "tosca.mo"
unless File.exists? path
  puts "***********************"
  puts "Missing traducted files. I am generating it for you with "
  puts "$ rake l10n:mo"
  %x[#{"rake l10n:mo"}]
  puts "***********************"
end

# Default conf for gettextlocalize, used for Dates & Currency
if defined? GettextLocalize
  GettextLocalize::app_name = App::Name
  GettextLocalize::app_version = App::Version
  GettextLocalize::default_locale = 'en_US'
  GettextLocalize::default_methods = [:param, :header, :session]
end

# Add new inflection rules using the following format
# (all these examples are active by default):
Inflector.inflections do |inflect|
  inflect.plural(/^(ox)$/i, '\1en')
  inflect.singular(/^(ox)en/i, '\1')
  inflect.uncountable %w( fish sheep )
end

# Preload of controllers/models during boot.
if RAILS_ENV == 'production'
  require_dependency 'application'
  path = File.join RAILS_ROOT, 'app', 'models'
  Dir.foreach( path ) { |f|
    silence_warnings{require_dependency f
    } if f =~ /\.rb$/}
  path = File.join RAILS_ROOT, 'app', 'controllers'
  Dir.foreach( path ) { |f|
    silence_warnings{require_dependency f
    } if f =~ /\.rb$/}
end
