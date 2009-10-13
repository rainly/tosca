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
class Comment < ActiveRecord::Base
  belongs_to :issue
  belongs_to :user
  belongs_to :statut
  belongs_to :severity
  belongs_to :engineer, :class_name => 'User',
    :conditions => 'users.client_id IS NULL'

  has_many :attachments, :dependent => :destroy

  validates_presence_of :user

  validate do |record|
    issue = record.issue
    if record.issue.nil?
      record.errors.add_to_base _('You must indicate a valid issue')
    end
    #We check if we are trying to change the status of the request,
    #but it has already the same status
    if (issue && issue.new_record? != true &&
        issue.first_comment_id != record.id &&
        issue.statut_id == record.statut_id &&
        record.new_record?)
      record.errors.add_to_base _('The status of this issue has already been changed.')
    end
    if (record.statut_id && record.private)
      record.errors.add_to_base _('You cannot privately change the status')
    end
    # Used by rails to know if validation is ok.
    record.errors.empty?
  end

  before_validation do |record|
    #If the status was changed and we do not specify a text, we generate a default text
    text = html2text(record.text).strip
    # TODO : find a way to make a square round
    # TODO : or find a good way to translate email
    if text.blank?
      if record.statut
        record.text << ( "La demande est désormais %s.<br/>" % _(record.statut.name) )
      end
      if record.engineer
        record.text << ( "Le responsable de la demande est désormais %s.<br/>" % _(record.engineer.name))
      end
    end
  end

  # State in words of the comment (private or public)
  def state
    ( private ? _("private") : _("public") )
  end

  # Used for outgoing mails feature, to keep track of the issue.
  def mail_id
    return "#{self.issue_id}_#{self.id}"
  end

  def name
    id.to_s
  end

  # This method search, create and add an attachment to the comment
  def add_attachments(params)
    attachments = params[:attachments]
    return true unless attachments && attachments.is_a?(Hash)
    attachments.each_value do |attachment|
      file = attachment[:file]
      next unless file && file.size > 0
      attach = Attachment.new(:file => file, :comment => self)
      if !attach.save # only error message of comment will be displayed
        error_message = attach.errors.full_messages.join('<br />')
        self.errors.add_to_base error_message
      end
    end
    self.errors.empty?
  end

  def fragments
    [ ]
  end

  def first_comment?
    return false unless self.issue
    (self.id == self.issue.first_comment_id)
  end

  # See ApplicationController#scope
  def self.set_private_scope()
    scope = { :conditions => [ 'comments.private = ?', false ] }
    self.scoped_methods << { :find => scope, :count => scope }
  end


  private

  # We destroy a few things, if appropriate
  # Attachments, Elapsed Time or Issue coherence is checked
  before_destroy :delete_dependancies
  def delete_dependancies
    issue = self.issue

    #We come from Issue.destroy
    return true unless issue

    # We MUST have at least the first comment in an issue
    return false if issue.first_comment_id == self.id

    # Updating last_comment pointer
    # TODO : Is this last_comment pointer really needed ?
    # Since we have the view cache, it does not seem pertinent, now
    if !self.private and issue.last_comment_id == self.id
      last_comment = issue.find_other_comment(self.id)
      if !last_comment
        self.errors.add_to_base(_('This issue seems to be unstable.'))
        return false
      end
      issue.update_attribute :last_comment_id, last_comment.id
    end

    issue.elapsed.remove(self) if issue.elapsed
    true
  end

  after_destroy :update_status
  def update_status
    return true if self.statut_id.nil? or self.statut_id == 0 or self.issue.nil?

    issue = self.issue
    options = { :order => 'created_on DESC', :conditions =>
      'comments.statut_id IS NOT NULL' }
    last_one = issue.comments.first(options)
    return true unless last_one
    issue.update_attribute(:statut_id, last_one.statut_id)
  end

  # update issue attributes, when creating a comment
  after_create :update_issue
  def update_issue
    fields = %w(statut_id engineer_id severity_id)
    issue = self.issue

    # Update all attributes
    if issue.first_comment_id != self.id
      fields.each do |attr|
        issue[attr] = self[attr] if self[attr] and issue[attr] != self[attr]
      end
    else
      fields.each { |attr| self[attr] = issue[attr] }
    end

    # auto-assignment to current engineer
    if issue.engineer_id.nil? && self.user.engineer?
      issue.engineer = self.user
    end

    # update cache of elapsed time
    contract = issue.contract
    rule = contract.rule
    if issue.elapsed.nil?
      issue.elapsed = Elapsed.new(issue)
      self.update_attribute :elapsed, rule.elapsed_on_create
    elsif !self.statut_id.nil?
      last_status_comment = issue.find_status_comment_before(self)
      elapsed = rule.compute_between(last_status_comment, self, contract)
      self.update_attribute :elapsed, elapsed
    end
    issue.elapsed.add(self)

    issue.last_comment_id = self.id unless self.private
    # no more a magic field : only comments update this field
    issue.updated_on = Time.now

    issue.save
  end

  # after_save :automatic_subscribtion
  # TODO : this subscription should be communicated, in a way or another
  # e.g. : by email or with the flash box.
=begin
  def automatic_subscribtion
    #Try to subscribe engineer that has deposit the comment
    Subscription.create(:user => self.user,
                        :model => self.issue) if self.user.engineer?

    #Try to subscribe new engineer who is responsible for the request
    Subscription.create(:user => self.engineer,
                        :model => self.issue) if self.engineer
    true
  end
=end

end
