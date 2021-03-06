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
class Issue < ActiveRecord::Base
  acts_as_taggable

  has_one :elapsed, :dependent => :destroy

  belongs_to :issuetype
  belongs_to :software
  belongs_to :version
  belongs_to :release
  belongs_to :severity
  belongs_to :statut
  # 3 peoples involved in an issue :
  #  1. The submitter (The one who has filled the issue)
  #  2. The engineer (The one who is currently in charged of this issue)
  #  3. The recipient (The one who has the problem)
  belongs_to :recipient, :class_name => 'User',
    :conditions => 'users.client_id IS NOT NULL'
  belongs_to :engineer, :class_name => 'User',
  :conditions => 'users.client_id IS NULL'
  belongs_to :submitter, :class_name => 'User',
    :foreign_key => 'submitter_id'

  belongs_to :contract
  belongs_to :contribution

  has_many :comments, :order => 'created_on ASC', :dependent => :destroy
  has_many :subscriptions, :as => :model, :dependent => :destroy
  has_many :issue_references, :order => 'linked_issue_id',
    :dependent => :destroy
  has_many :issue_backreferences, :foreign_key => 'linked_issue_id',
    :class_name => 'IssueReference', :order => 'issue_id'

  named_scope :actives, lambda { |contract_ids| { :conditions =>
      { :statut_id => Statut::OPENED, :contract_id => contract_ids }
    }
  }
  named_scope :inactives, lambda { |contract_ids| { :conditions =>
      { :statut_id => Statut::CLOSED, :contract_id => contract_ids }
    }
  }

  # Key pointers to the issue history
  # /!\ used to store the description /!\
  belongs_to :first_comment, :class_name => "Comment",
    :foreign_key => "first_comment_id"
  # /!\ the last _public_ comment /!\
  belongs_to :last_comment, :class_name => "Comment",
    :foreign_key => "last_comment_id"

  # Validation
  validates_presence_of :resume, :contract, :description, :recipient,
    :statut, :severity
  validates_length_of :resume, :within => 4..70
  validates_length_of :description, :minimum => 5

  # Description was moved to first comment mainly for
  # DB performance reason : it's easier to be fast without black hole
  # like TEXT column. See #description for the trick around this field.
  attr_accessor :description

  validate do |record|
    if record.contract.nil? || record.recipient.nil? ||
        (record.contract.client_id != record.recipient.client_id)
      record.errors.add_to_base _('The client of this contract is not consistant with the client of this recipient.')
    end
  end

  # only comments or creation update timestamps
  # coz it's used by customer to see if a comment has been made
  record_timestamps = false


  # self-explanatory
  CLOSED = "issues.statut_id IN (#{Statut::CLOSED.join(',')})" unless defined? CLOSED
  OPENED = "issues.statut_id IN (#{Statut::OPENED.join(',')})" unless defined? OPENED

  # See ApplicationController#scope
  def self.set_scope(user)
    scope = { :conditions =>
      [ 'issues.contract_id IN (?)', user.contract_ids ] }
    self.scoped_methods << { :find => scope, :count => scope }
  end

  def to_param
    "#{id}-#{resume.asciify}"
  end

  def name
    resume
  end

  def pretty_id
    "[#{sprintf "%06d", self.id}]"
  end

  def contract_id=(new_id)
    new_contract = Contract.find(new_id)
    rules_changed = true if !self.new_record? && new_contract.rule_type != self.contract.rule_type
    # we need to update this attribute before refreshing elapsed cache.
    write_attribute(:contract_id, new_id)
    self.contract = new_contract
    if rules_changed
      self.comments.each { |c| c.update_attribute :elapsed, 0 }
      self.reset_elapsed
    end
  end

  def full_software_name
    result = ""
    result = software.name if self.software
    result = version.full_software_name if self.version
    result = release.full_software_name if self.release
    result
  end

  # Dirty hacks are really bad ...
  def client_name
    (self.respond_to?(:clients_name) ? self.clients_name : self.client.name)
  end
  # Dirty hacks are really bad ...
  def software_name
    if self.respond_to?(:softwares_name)
      self.softwares_name
    elsif self.software
      self.software.name
    else
      '-'
    end
  end

  # It associates issue with the correct id since
  # we maintain both the 2 cases.
  # See _form of issue for more details
  def associate_software(revisions)
    return unless revisions
    id = revisions[1..-1].to_i # revisions is a String, not an Array
    case revisions.first
    when 'v'
      self.version_id = id
    when 'r'
      self.release_id = id
    end
  end

  # Remanent fields are those which persists after the first submit
  # It /!\ MUST /!^ be an _id field. See IssuesController#create.
  def self.remanent_fields
    [ :contract_id, :recipient_id, :issuetype_id, :severity_id,
      :software_id, :engineer_id, :version_id ]
  end

  # Used in the cache/sweeper system
  def fragments
    [ %r{issues/#{self.id}} ]
  end

  def elapsed_formatted
    contract.rule.elapsed_formatted(self.elapsed.until_now, contract)
  end

  def find_other_comment(comment_id)
    cond = [ 'comments.private <> ? AND comments.id <> ?', true, comment_id ]
    self.comments.first(:conditions => cond)
  end

  def find_status_comment_before(comment)
    options = { :order => 'created_on DESC', :conditions =>
      [ 'comments.statut_id IS NOT NULL AND comments.created_on < ?',
        comment.created_on ]}
    self.comments.first(options)
  end

  def last_status_comment
    options = { :order => 'created_on DESC', :conditions =>
      'comments.statut_id IS NOT NULL' }
    self.comments.first(options)
  end

  def time_running?
    Statut::Running.include? self.statut_id
  end

  # set the default for a new issue
  def set_defaults(user, params)
    return unless self.new_record?
    # self-assignment
    if user.engineer?
      self.engineer_id = user.id
    else
      self.recipient_id = user.id
    end
    # without severity, by default
    self.severity_id = 4
    # if we came from software view, it's sets automatically
    self.software_id = params[:software_id]
  end

  # Description was moved to first comment mainly for
  # DB performance reason : it's easier to be fast without black hole
  # like TEXT column
  def description
    (first_comment ? first_comment.text : @description)
  end

  # /!\ Dirty Hack Warning /!\
  # We use finder for overused view mainly (issues/list)
  # It's about 40% faster with this crap (from 2.8 r/s to 4.0 r/s)
  # it's not enough, but a good start :)
  SELECT_LIST = 'issues.*, severities.name as severities_name,
    softwares.name as softwares_name, clients.name as clients_name,
    issuetypes.name as issuetypes_name, statuts.name as statuts_name' unless defined? SELECT_LIST
  JOINS_LIST = 'INNER JOIN severities ON severities.id=issues.severity_id
    INNER JOIN users ON users.id = issues.recipient_id
    INNER JOIN clients ON clients.id = users.client_id
    INNER JOIN issuetypes ON issuetypes.id = issues.issuetype_id
    INNER JOIN statuts ON statuts.id = issues.statut_id
    LEFT OUTER JOIN softwares ON softwares.id = issues.software_id ' unless defined? JOINS_LIST

  def self.content_columns
    @content_columns ||= columns.reject { |c| c.primary ||
      c.name =~ /(_id|_on|resume)$/ ||
      c.name == inheritance_column }
  end

  def client
    @client ||= ( recipient ? recipient.client : nil )
  end

  # An issue is critical if :
  # - The CNS for the workaround is > 50% and the issue was never workarounded
  # - The CNS for the correction is > 50% and the issue was never corrected
  # - The issue is not suspended
  # - The issue has no comments for the past @param no_modifications
  def critical?(no_modifications = 15.days.ago)
    return true if self.time_running?
    #We check for correction before, because an issue that was corrected is workarounded in the Elapse model
    return true if not self.elapsed.correction? and self.elapsed.correction_progress(self.interval) > 0.5
    return true if not self.elapsed.workaround? and self.elapsed.workaround_progress(self.interval) > 0.5
    return true if self.updated_on <= no_modifications
    return false
  end

  # Used for migration or if there is an issue on the computing of issue
  # It can be used on all issue with a line like this in the console :
  # <tt>Issue.all.each{|r| r.reset_elapsed }</tt>
  def reset_elapsed
    # clean previous existing elapsed
    Elapsed.destroy_all(['elapseds.issue_id = ?', self.id])

    rule = self.contract.rule
    self.elapsed = Elapsed.new(self)
    options = { :conditions => '(comments.statut_id IS NOT NULL OR comments.elapsed != 0)',
      :order => "comments.created_on ASC" }
    life_cycle = self.comments.all(options)

    # first one is different : it's the submission of the issue
    life_cycle.first.update_attribute :elapsed, rule.elapsed_on_create

    # all the others
    previous, contract = life_cycle.first, self.contract
    life_cycle.each do |step| # a step is a Comment object
      step.update_attribute :elapsed, rule.compute_between(previous, step, contract)
      self.elapsed.add step
      previous = step
    end
    self.save!
  end

  # TODO : add a commitment_id to Issue Table. This helper method
  # clearly slows uselessly Tosca.
  def commitment
    return nil unless contract_id && severity_id && issuetype_id
    self.contract.commitments.first(:conditions =>
        {:issuetype_id => self.issuetype_id, :severity_id => self.severity_id})
  end

  # useful shortcut
  def interval
    self.contract.interval
  end

  # We have to make it in two steps, coz of the whole validation. If you
  # manage to cover all the case in one method, MLO will offer you a beer ;)
  before_create :create_first_comment
  after_create :do_after_create

  # Generate the cc for an outgoing mail for this issue
  # private indicates if it's reserved for internal use or not
  def compute_copy(private = false)
    # subscribers_emails = subscribers.collect(&:email_name).join(', ')
    if private
      contract.internal_ml
    else
      res = []
      [ contract.customer_ml, mail_cc, contract.internal_ml ].each do |m|
        res << m unless m.nil? or m.blank?
      end
      res.join(', ')
    end
  end

  # Generate the to for an outgoing mail for this issue
  def compute_recipients(private = false)
    res = []
    # The client is not informed of private messages
    res << recipient.email_name unless private
    # Issue are not assigned, by default
    res << engineer.email_name if engineer
    res.join(', ')
  end

  def subscribed?(user)
    self.subscribers.include?(user)
  end

  def subscribers
    software_subscribers = []
    (self.software ? self.software.subscribers : []).each do |s|
      software_subscribers << s if s.contracts.include?(self.contract)
    end
    res = self.subscriptions.collect(&:user).
      concat(self.contract.subscribers).
      concat(software_subscribers)
    res.uniq!
    res
  end

  #Find the pending requests of a user
  def self.find_pending_user(user)
    options, conditions = build_conditions_pending

    if user.recipient?
      conditions.first << 'issues.recipient_id IN (?)'
    else
      conditions.first << 'issues.engineer_id IN (?)'
    end
    own_id = user.id
    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    conditions << [ own_id ]
    Issue.all(options)
  end

  #Find the pending requests from a list of contracts
  def self.find_pending_contracts(contract_ids)
    options, conditions = build_conditions_pending

    conditions.first << 'issues.contract_id IN (?)'
    conditions[0] = conditions.first.join(' AND ')
    options[:conditions] = conditions

    conditions << contract_ids
    Issue.all(options)
  end

  private
  # TODO : Use memoization as described here, when Tosca is on Rails >= 2.2
  # http://www.railway.at/articles/2008/09/20/a-guide-to-memoization
  def self.build_conditions_pending
    options = { :order => 'issues.updated_on DESC',
      :select => Issue::SELECT_LIST, :joins => Issue::JOINS_LIST }
    conditions = [ [ ] ]

    options[:joins] += 'INNER JOIN comments ON comments.id = issues.last_comment_id'

    conditions.first << 'statuts.active = ?'
    conditions << true
    conditions.first << '(issues.expected_on < ? OR issues.expected_on IS NULL)'
    conditions << Time.now

    [ options, conditions ]
  end

  def create_first_comment
    self.created_on = self.updated_on = Time.now
    self.first_comment = Comment.new do |c|
      #We use id's because it's quicker
      c.text = self.description
      c.engineer_id = self.engineer_id
      c.issue = self
      c.severity_id = self.severity_id
      c.statut_id = self.statut_id
      c.user_id = self.submitter_id
    end
  end

  def do_after_create
    self.first_comment.update_attribute :issue_id, self.id
  end

end
