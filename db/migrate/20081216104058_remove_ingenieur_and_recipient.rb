#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class RemoveIngenieurAndRecipient < ActiveRecord::Migration

  class Ingenieur < ActiveRecord::Base
    belongs_to :user
    has_many :knowledges
    has_many :issues
    has_many :phonecalls
    has_many :comments
    has_many :contributions
  end

  class Recipient < ActiveRecord::Base
    belongs_to :user
    has_many :phonecalls
    has_many :issues
  end

  class Phonecall < ActiveRecord::Base
  end

  class Comment < ActiveRecord::Base
    belongs_to :user
    belongs_to :ingenieur
  end

  class Issue < ActiveRecord::Base
    belongs_to :recipient
  end

  def self.up
    remove_column :ingenieurs, :image_id
    remove_column :users, :client

    add_column :users, :client_id, :integer, :default => nil, :null => true

    add_column :knowledges, :engineer_id, :integer
    add_index :knowledges, :engineer_id
    add_column :issues, :engineer_id, :integer
    add_index :issues, :engineer_id
    add_column :phonecalls, :engineer_id, :integer
    add_index :phonecalls, :engineer_id
    add_column :comments, :engineer_id, :integer
    add_index :comments, :engineer_id
    add_column :contributions, :engineer_id, :integer
    add_index :contributions, :engineer_id

    add_column :issues, :new_recipient_id, :integer
    add_column :phonecalls, :new_recipient_id, :integer

    Ingenieur.all.each do |i|
      user = i.user

      i.knowledges.each do |k|
        k.update_attribute(:engineer_id, user.id)
      end

      i.issues.each do |d|
        d.update_attribute(:engineer_id, user.id)
      end

      i.comments.each do |c|
        c.update_attribute(:engineer_id, user.id)
      end

      i.contributions.each do |c|
        c.update_attribute(:engineer_id, user.id)
      end
    end

    Recipient.all.each do |r|
      r.user.update_attribute(:client_id, r.client_id)

      r.phonecalls.each do |p|
        p.update_attribute(:new_recipient_id, r.user.id)
      end
      r.issues.each do |i|
        i.update_attribute(:new_recipient_id, r.user.id)
      end
    end

    remove_column :issues, :recipient_id
    remove_column :phonecalls, :recipient_id
    rename_column :issues, :new_recipient_id, :recipient_id
    rename_column :phonecalls, :new_recipient_id, :recipient_id
    add_index :issues, :recipient_id
    add_index :phonecalls, :recipient_id

    remove_column :knowledges, :ingenieur_id
    remove_column :issues, :ingenieur_id
    remove_column :phonecalls, :ingenieur_id
    remove_column :comments, :ingenieur_id
    remove_column :contributions, :ingenieur_id

    drop_table :ingenieurs
    drop_table :recipients
  end

  def self.down
  end
end
