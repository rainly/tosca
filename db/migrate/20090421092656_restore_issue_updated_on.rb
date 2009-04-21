class RestoreIssueUpdatedOn < ActiveRecord::Migration
  def self.up
    Issue.record_timestamps = false
    Issue.all.each do |i|
      comment = i.last_comment
      comment = i.comments.last if comment.nil?
      i.update_attribute(:updated_on, comment.updated_on)
    end
    Issue.record_timestamps = true
  end

  def self.down
  end
end
