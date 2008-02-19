class Elapsed < ActiveRecord::Base
  belongs_to :demande

  # self-update with a comment
    # Please ensure that add() and remove() are consistent
  def add(comment)
    self.until_now += comment.elapsed

    if self.taken_into_account.nil? && comment.statut_id == 2
      self.taken_into_account = self.until_now
    end
    if self.workaround.nil? && comment.statut_id == 5
      self.workaround = self.until_now
    end
    if self.correction.nil? && comment.statut_id == 6
      self.correction = self.until_now
    end

    save
  end

  # called when the comment is destroyed.
  # Please ensure that add() and remove() are consistent
  def remove(comment)
    self.until_now -= comment.elapsed

    if !self.taken_into_account.nil? && comment.statut_id == 2
      self.taken_into_account = nil
    end
    if !self.workaround.nil? && comment.statut_id == 5
      self.workaround = nil
    end
    if !self.correction.nil? && comment.statut_id == 6
      self.correction = nil
    end

    save
  end

  # TODO
  def to_s
    '-'
  end
end
