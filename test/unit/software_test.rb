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
require File.dirname(__FILE__) + '/../test_helper'

class SoftwareTest < ActiveSupport::TestCase
  include ActionController::TestProcess

  def test_to_strings
    check_strings Software
  end

  def test_scope
    Software.set_public_scope
    assert Software.all(:conditions => {:private => true}).empty?
    Software.remove_scope
    assert !Software.all(:conditions => {:private => true}).empty?

    assert Release.scope_contract?
    contract_id = Contract.first(:order => :id).id
    Release.set_scope([contract_id])
    Release.all.each{|r| assert r.contract_id === contract_id}
    Release.remove_scope
  end

  def test_arrays
    check_arrays Software
  end

  def test_and_upload_logos
    upload_logo('/files/Logo_OpenOffice.org.png', 'image/svg', 2)
    upload_logo('/files/logo_firefox.gif', 'image/gif', 4)
    upload_logo('/files/logo_cvs.gif', 'image/gif', 5)

    assert !@software.picture.image.blank?
  end

  # We need to upload files in order to have working logo in test environment.
  def upload_logo(path, mimetype, id)
    @software ||= Software.first(:order => :id)
    image_file = fixture_file_upload(path, mimetype)
    Picture.find(id).destroy
    image = Picture.new(:image => image_file, :software => @software)
    image.id = id
    image.save!
  end

  def test_contracts
    Software.all.each{|s| s.contracts}
  end

  def test_release_contracts
    Software.all.each do |s|
      Contract.all.each do |c|
        s.releases_contract(c)
      end
    end
  end

end
