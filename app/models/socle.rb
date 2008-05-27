class Socle < ActiveRecord::Base
  acts_as_reportable
  has_one :machine
  has_many :binaires, :include => :paquet
  has_many :paquets, :through => :binaires, :group => 'paquets.id'

  has_and_belongs_to_many :clients


  def self.set_scope(client_ids)
    self.scoped_methods << { :find => { :conditions =>
        [ 'clients_socles.client_id IN (?)', client_ids ], :joins =>
        'INNER JOIN clients_socles ON clients_socles.socle_id=socles.id'} }
  end

end
