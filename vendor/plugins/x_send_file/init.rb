if config.frameworks.include? :action_controller
  require 'x_send_file'

  # Add x_send_file to ActionController
  ActionController::Base.send(:include, XSendFile::Controller)
end
