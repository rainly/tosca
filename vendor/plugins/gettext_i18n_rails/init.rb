begin
  require 'config/initializers/session_store'
rescue LoadError
  # weird bug, when run with rake rails reports error that session
  # store is not configured, this fixes it somewhat...
end

Rails.configuration.after_initialize do
  require 'gettext_i18n_rails'
end
