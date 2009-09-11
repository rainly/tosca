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
class Attachment < ActiveRecord::Base
  file_column :file, :fix_file_extensions => nil,
    :magick => {
      :versions => {
        :fit_size => { :size => "800x600>" }
      }
    }

  belongs_to :comment
  has_one :issue, :through => :comment

  validates_presence_of :file, :comment

  def name
    return file[/[._ \-a-zA-Z0-9]*$/]
  end

  # special scope : only used for file downloads
  # see FilesController
  def self.set_scope(user)
    @@joins ||= %q(LEFT OUTER JOIN comments ON attachments.comment_id = comments.id
                   LEFT OUTER JOIN issues ON issues.id = comments.issue_id)
    self.scoped_methods << { :find => {
       :conditions => [ 'issues.contract_id IN (?)', user.contract_ids ],
       :joins => @@joins }
    }
  end

end
