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
class Contract < ActiveRecord::Base
  belongs_to :client
  belongs_to :rule, :polymorphic => true
  belongs_to :creator, :class_name => 'User'
  belongs_to :salesman, :class_name => 'User'
  belongs_to :tam, :class_name => 'User'

  has_many :issues, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :releases, :dependent => :destroy

  has_many :subscriptions, :as => :model, :dependent => :destroy

  has_and_belongs_to_many :versions, :order => 'versions.name DESC', :uniq => true

  has_and_belongs_to_many :commitments, :uniq => true, :order =>
    'issuetype_id, severity_id', :include => [:severity,:issuetype]
  has_and_belongs_to_many :users, :order => 'users.name', :uniq => true
  # Those 2 ones are helpers, not _real_ relation ship
  has_and_belongs_to_many :engineer_users, :class_name => 'User',
    :conditions => 'users.client_id IS NULL',
    :order => 'users.name ASC'
  has_and_belongs_to_many :recipient_users, :class_name => 'User',
    :conditions => 'users.client_id IS NOT NULL',
    :order => 'users.name ASC'
  has_and_belongs_to_many :teams, :order => 'teams.name', :uniq => true

  validates_presence_of :client, :rule, :creator, :start_date, :end_date
  validates_numericality_of :opening_time, :closing_time,
    :only_integer => true
  validates_inclusion_of :opening_time, :closing_time, :in => 0..24

  validate :must_open_before_close

  def must_open_before_close
    valid = true
    if self.opening_time.to_i > self.closing_time.to_i
      self.errors.add_to_base("The schedules of this contract are invalid.")
      valid = false
    end
    valid
  end

  Rules = [ 'Rules::Credit', 'Rules::Component' ] unless defined? Contract::Rules
  INNER_JOIN_TEAMS = 'INNER JOIN contracts_teams ct ON ct.contract_id=contracts.id'

  def self.set_scope(user)
    self.scoped_methods << { :find => { :conditions =>
        [ 'contracts.id IN (?)', user.contract_ids ] } }
  end

  def engineers
    engineers = self.engineer_users
    engineers.concat(self.teams.collect { |t| t.users }.flatten).uniq!
    engineers
  end

  def credit?
    rule_type == Rules.first
  end

  def interval_in_seconds
    return (closing_time - opening_time) * 1.hour
  end

  def interval
    closing_time - opening_time
  end

  def softwares
    Software.all(:conditions => { "contracts.id" => self.id },
      :joins => { :versions => :contracts },
      :group => 'softwares.id', # Allows to have uniqueness in results
      :order => 'softwares.name')
  end

  def find_recipients_select
    options = { :conditions => ['users.inactive = ?', false]}
    self.recipient_users.all(options).collect { |u| [u.name, u.id ] }
  end

  def start_date_formatted
    display_time read_attribute(:start_date)
  end

  def end_date_formatted
    display_time read_attribute(:end_date)
  end

  def find_commitment(issue)
    options = { :conditions =>
      [ 'commitments.issuetype_id = ? AND severity_id = ?',
        issue.issuetype_id, issue.severity_id ] }
    self.commitments.first(options)
  end

  def issuetypes
    joins = 'INNER JOIN commitments ON commitments.issuetype_id = issuetypes.id '
    joins << 'INNER JOIN commitments_contracts ON commitments.id = commitments_contracts.commitment_id'
    conditions = [ 'commitments_contracts.contract_id = ? ', id ]
    Issuetype.all(
                     :select => "DISTINCT issuetypes.*",
                     :conditions => conditions,
                     :joins => joins)
  end

  INCLUDE = [:client]
  ORDER = 'clients.name ASC'
  OPTIONS = { :include => INCLUDE, :order => ORDER, :conditions =>
    ["clients.inactive = ?", false] }

  def name
    specialisation = read_attribute(:name)
    res = (client ? client.name : '-')
    res = "#{res} - #{specialisation}" unless specialisation.blank?
    res
  end

  def total_elapsed
    total = 0
    self.issues.each do |r|
      total += r.elapsed.until_now
    end
    total
  end

  def subscribers
    self.subscriptions.collect(&:user)
  end

  def subscribed?(user)
    return false if user.nil?
    conditions = {:user_id => user.id,
      :model_type => 'Contract', :model_id => self.id}
    Subscription.count(:conditions => conditions) >= 1
  end

  private

  before_save :update_users
  def update_users
    # To make sure we have only once an engineer
    self.engineer_users = self.engineer_users -
      (self.teams.collect(&:users).flatten)
    # removed users should also be updated
    res = []
    res << self.users << self.teams.collect(&:users)
    if self.id
      res << Contract.find(self.id).users
      res << Contract.find(self.id).teams.collect(&:users)
    end
    res.flatten!
    res.uniq!
    res.each{|u| u.save!}
  end

  # Ensure tam is subscribed
  #  after_save do |record|
  #    unless record.subscribed?(record.tam)
  #      Subscription.create(:user => record.tam, :model => record)
  #    end
  #  end

end
