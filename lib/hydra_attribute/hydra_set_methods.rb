module HydraAttribute
  class MissingAttributeInHydraSetError < NoMethodError
  end

  module HydraSetMethods
    extend ActiveSupport::Concern

    included do
      alias_method_chain :write_attribute, :hydra_set_id
    end

    module ClassMethods
      extend Memoize

      def hydra_sets
        HydraSet.where(entity_type: base_class.model_name)
      end
      hydra_memoize :hydra_sets

      def hydra_set(identifier)
        hydra_sets.find do |hydra_set|
          hydra_set.id == identifier || hydra_set.name == identifier
        end
      end
      hydra_memoize :hydra_set

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_#{prefix}s
            hydra_sets.map(&:#{prefix})
          end
          hydra_memoize :hydra_set_#{prefix}s
        EOS
      end

      def clear_hydra_set_cache!
        @hydra_sets      = nil
        @hydra_set       = nil
        @hydra_set_ids   = nil
        @hydra_set_names = nil
      end
    end

    def write_attribute_with_hydra_set_id(attr_name, value)
      if attr_name.to_s == 'hydra_set_id'
        self.class.hydra_attribute_backend_types.each do |backend_type|
          hydra_value_association(backend_type).clear_cache!
        end
        @hydra_value_models = nil
      end
      write_attribute_without_hydra_set_id(attr_name, value)
    end
  end
end