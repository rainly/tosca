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
class Software < ActiveRecord::Base
  acts_as_taggable

  belongs_to :picture, :dependent => :destroy
  belongs_to :license
  belongs_to :group

  has_many :contributions, :dependent => :destroy
  has_many :knowledges, :dependent => :destroy
  has_many :issues, :dependent => :destroy
  has_many :hyperlinks, :dependent => :destroy, :as => :model
  has_many :releases, :through => :versions
  has_many :versions, :order => "versions.name DESC", :dependent => :destroy
  has_many :subscriptions, :through => :knowledges, :dependent => :destroy

  has_and_belongs_to_many :skills, :uniq => true

  validates_presence_of :name

  # form_test_helper is buggy and does not read skill_ids[] correctly
  # And we needs this test more than this validation
  # validates_length_of :skills, :minimum => 1

  # See ApplicationController#scope
  def self.set_index_scope(user)
    @@scope_joins ||= " LEFT OUTER JOIN `versions` ON versions.software_id = softwares.id INNER JOIN contracts_versions ON versions.id = contracts_versions.version_id "
    self.scoped_methods << { :find => { :conditions =>
        [ 'contracts_versions.contract_id IN (?)', user.contract_ids ],
        :joins => @@scope_joins } }
  end

  # See ApplicationController#scope
  def self.set_public_scope
    self.scoped_methods << { :find => { :conditions =>
        { :private => false } } }
  end

  def self.content_columns
    @content_columns ||= columns.reject { |c|
      c.primary || c.name =~ /(_id|_count|referent|description)$/
    }
  end

  def to_param
    "#{id}-#{name.asciify}"
  end

  def contracts
    joins = 'INNER JOIN contracts_versions cv ON cv.contract_id = contracts.id'
    conditions = [ 'cv.version_id IN (?)', self.version_ids ]
    Contract.all(:conditions => conditions, :joins => joins,
                 :group => 'contracts.id')
  end

  ReleasesContract = Struct.new(:name, :id, :type)
  # Returns all the version and the last release of each version
  # Returns Array of ContractReleases
  # Call it like : Software.first.releases_contract(Contract.first.id)
  # It's used in _form4versions of issues_controller.
  # /!\ Do NOT touch this method without looking at
  #         1. _form4versions /!\
  #         2. issues/_version.html.erb /!\
  def releases_contract(contract_id)
    result = []
    self.versions.all(
      :conditions => { "contracts.id" =>  contract_id },
      :joins => :contracts, :order => "versions.id").each do |v|
      releases = v.releases
      if releases.empty?
        result.push ReleasesContract.new(v.full_name, v.id, Version)
      else
       r = releases.sort!.first
       result.push ReleasesContract.new(r.full_name, r.id, Release)
      end
    end
    result
  end

  def subscribers
    self.subscriptions.collect(&:user)
  end

  include Comparable
  def <=>(other)
    self.name <=> other.name
  end

end
