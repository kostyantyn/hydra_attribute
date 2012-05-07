module HydraAttribute
  module ActiveRecord
    module Relation
      define_method HydraAttribute.config.relation_execute_method do
        records = super()
        if records.many?
          records.first.class.base_class.hydra_attribute_types.each do |type|
            relation = HydraAttribute.config.association(type)
            record   = records.detect { |record| record.class.reflect_on_association(relation).present? }
            if record and !record.association(relation).loaded?
              ::ActiveRecord::Associations::Preloader.new(records, relation).run
            end
          end
        end
        records
      end
    end
  end
end