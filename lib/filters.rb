module Filters

  module Shared
    def self.extended(base)
      base.class_eval do
        define_method(:initialize) { |params, *args|
          if params.is_a? Hash
            params.each {|key, value|
              if key =~ /_id/ and value.is_a? String and not value.blank?
                send("#{key}=", value.to_i)
              else
                send("#{key}=", value)
              end
            }
          else
            super(*args.unshift(params))
          end
        }
      end
    end
  end

  class Knowledges < Struct.new('Knowledges', :ingenieur_id,
                                :logiciel_id, :competence_id)
    extend Shared
  end

  class Contributions < Struct.new('Contributions', :software, :ingenieur_id,
                             :contribution, :etatreversement_id, :contrat_id)
    extend Shared
  end

  class Softwares < Struct.new('Softwares', :software, :groupe_id,
                               :contrat_id, :description, :competence_id )
    extend Shared
  end

  class Calls < Struct.new('Calls', :ingenieur_id, :beneficiaire_id,
                            :contrat_id, :after, :before)
    extend Shared
  end

  class Requests < Struct.new('Requests', :text, :client_id, :ingenieur_id,
                              :typedemande_id, :severite_id, :statut_id, :active)
    extend Shared
  end

  class Accounts < Struct.new('Accounts', :name, :client_id, :role_id)
    extend Shared
  end

  # build the conditions query, from a well specified array of filters
  # Specification of a filter f :
  # [ namespace, field, database field, operation ]
  # And params[f[0]][f[1]] contains the value searched
  # <hr />
  # There are 3 kind of operation, expressed in symbol
  # :like, :in & :equal
  # Call it like :
  # conditions = Filters.build_conditions(params, [
  #   ['logiciel', 'name', 'paquets.name', :like ],
  #   ['logiciel', 'description', 'paquets.description', :like ],
  #   ['filters', 'groupe_id', 'logiciels.groupe_id', :equal ],
  #   ['filters', 'competence_id', 'competences_logiciels.competence_id', :equal ],
  #   ['filters', 'client_id', ' paquets.contrat_id', :in ]
  # ])
  # flash[:conditions] = options[:conditions] = conditions
  # This helpers is here mainly for avoiding SQL injection.
  # you MUST use it, if you don't want to burn in hell during your seven next lives
  # special_conditions allows to put additional conditions to the filters.
  # it must be a string !
  # TODO : rework this helper in order to avoid the :dual_like hacks.
  def self.build_conditions(params, filters, special_conditions = nil)
    conditions = [[]]
    condition_0 = conditions.first
    filters.each { |f|
      value = params[f.first]
      unless value.blank?
        query = case f.last
                when :equal
                  "#{f[1]}=?"
                when :greater_than
                  "#{f[1]}>?"
                when :lesser_than
                  "#{f[1]}<?"
                when :dual_like
                  "(#{f[1]} LIKE (?) OR #{f[2]} LIKE (?))"
                else
                  "#{f[1]} #{f[2]} (?)"
                end
        condition_0.push query
        # now, fill in parameters of the query
        case f.last
        when :like
          conditions.push "%#{value}%"
        when :dual_like
          temp = "%#{value}%"
          conditions.push temp, temp
        else
          conditions.push value
        end
      end
    }
    condition_0.push special_conditions if special_conditions.is_a? String
    if condition_0.empty?
      nil
    else
      conditions[0] = condition_0.join(' AND ')
      conditions
    end
  end
end
