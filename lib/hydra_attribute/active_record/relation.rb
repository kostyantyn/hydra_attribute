require 'hydra_attribute/active_record/relation/calculations'
require 'hydra_attribute/active_record/relation/query_methods'
require 'hydra_attribute/active_record/association_preloader'

module HydraAttribute
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        include Calculation
        include QueryMethods
      end

      def exec_queries
        records = super
        return records if records.empty?

        AssociationPreloader.run(self, records)
        records
      end

    end
  end
end
