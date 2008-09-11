#
# Copyright (c) 2006-2008 Linagora
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
module DigestReporting

  #contract is a Contract, requests is an array of DigestRequests
  DigestContracts = Struct.new(:contract, :requests)
  #request is a Request, request_at is a Request, comments is an array of Commentaire
  DigestRequests = Struct.new(:request, :request_at, :comments)

  def digest_result(period)
    @period = period
    @period = "year" if period.blank?
    updated = Time.now.send("beginning_of_#{@period}")
    # We must localise it after getting the (english) helper for the start date
    @period = _(@period)

    options = { :conditions => [ "updated_on >= ? ", updated ],
     :order => "contract_id ASC", :include => [:typerequest, :severite, :statut]}
    requests = Request.find(:all, options)

    @result = Array.new
    last_contract_id = nil
    requests.each do |r|
      if last_contract_id != r.contract_id
        dc = DigestContracts.new
        dc.contract = r.contract
        dc.requests = Array.new
        @result.push(dc)
      end

      options = { :conditions => [ "created_on >= ? ", updated ] }

      dr = DigestRequests.new
      dr.request = r
      dr.request_at = r.state_at(updated)
      dr.comments = r.commentaires.find(:all, options)
      @result.last.requests.push(dr)

      last_contract_id = r.contract_id
    end
  end

  #important is an array of Request, other is an array of DigestContracts
  DigestManagers = Struct.new(:important, :other)

  def digest_managers(period)
    @period = period
    @period = "year" if period.blank?
    updated = Time.now.send("beginning_of_#{@period}")
    # We must localise it after getting the (english) helper for the start date
    @period = _(@period)
    
    options = { :conditions => [ "updated_on >= ? ", updated ],
     :order => "contract_id ASC", :include => [:typerequest, :severite, :statut]}
    requests = Request.find(:all, options)
    
    @result = DigestManagers.new    
    @result.important = Array.new
    @result.other = Array.new
    last_contract_id = nil
    requests.each do |r|
      if last_contract_id != r.contract_id and not r.critical?
        dc = DigestContracts.new
        dc.contract = r.contract
        dc.requests = Array.new
        @result.other.push(dc)
      end
      
      if r.critical?
        @result.important.push(r)
      else 
 
        options = { :conditions => [ "created_on >= ? ", updated ] }

        dr  = DigestRequests.new
        dr.request = r
        dr.request_at = r.state_at(updated)
        dr.comments = r.commentaires.find(:all, options)
        @result.other.last.requests.push(dr)
      end

      last_contract_id = r.contract_id
    end

  end

end