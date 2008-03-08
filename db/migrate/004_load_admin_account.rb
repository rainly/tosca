class LoadAdminAccount < ActiveRecord::Migration
  class Identifiant < ActiveRecord::Base
    has_one :ingenieur, :dependent => :destroy
  end
  class Ingenieur < ActiveRecord::Base; end

  def self.up
    # Do not erase existing accounts
    return unless Identifiant.count == 0

    admin_id, manager_id, expert_id, customer_id, viewer_id = 1,2,3,4,5
    # Id must be setted aside, unless it won't works as expected
    ### as of Rails 1.2.x
    user = Identifiant.new(:login => 'admin', :nom => 'Admin', :role_id =>
                           admin_id, :password =>
                           Digest::SHA1.hexdigest("linagora--#{'admin'}--"),
                           :informations => "")
    user.id = 1
    user.save!
    Ingenieur.create(:identifiant_id => 1)
  end

  def self.down
    admin = Identifiant.find_by_login('admin')
    admin.destroy if admin
  end
end
