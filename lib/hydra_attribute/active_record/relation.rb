module HydraAttribute
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        include QueryMethods
      end

      define_method HydraAttribute.config.relation_execute_method do
        records = super()
        if records.many?
          records.first.class.hydra_attribute_types.each do |type|
            association = HydraAttribute.config.association(type)
            unless records.first.association(association).loaded?
              ::ActiveRecord::Associations::Preloader.new(records, association).run
            end
          end
        end
        records
      end

    end
  end
end