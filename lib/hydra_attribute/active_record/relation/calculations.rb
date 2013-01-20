module HydraAttribute
  module ActiveRecord
    module Relation
      module Calculation
        extend ActiveSupport::Concern

        included do
          attr_accessor :hydra_attribute_performs_calculation
        end

        # Notifies +#build_arel+ method that it builds query for calculation
        def execute_simple_calculation(operation, column_name, distinct)
          self.hydra_attribute_performs_calculation = true
          super(operation, column_name, distinct)
        end
      end
    end
  end
end
