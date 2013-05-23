require 'fog/core/collection'
require 'fog/storm_on_demand/models/compute/pool'

module Fog
  module Compute
    class StormOnDemand

      class Pools < Fog::Collection
        model Fog::Compute::StormOnDemand::Pool

        def create(options)
          p = service.create_pool(options).body
          new(p)
        end

        def get(uniq_id)
          p = service.get_pool(:uniq_id => uniq_id).body
          new(p)
        end

        def get_assignments(options={})
          service.get_assignments(options).body['items']
        end
        
      end
    end
  end
end
