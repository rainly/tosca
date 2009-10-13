# Workaround for mongrel with Rails >= 2.3.x
# see https://rails.lighthouseapp.com/projects/8994/tickets/2319

module ActionController
  class AbstractRequest < ActionController::Request
    def self.relative_url_root=(path)
      ActionController::Base.relative_url_root=(path)
    end
    def self.relative_url_root
      ActionController::Base.relative_url_root
    end
  end
end if defined? Mongrel
