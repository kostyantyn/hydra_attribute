module HydraAttribute
  class MissingAttributeInHydraSetError < NoMethodError
  end

  module HydraSetMethods
    extend ActiveSupport::Concern

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
        [:@hydra_sets, :@hydra_set, :@hydra_set_ids, :@hydra_set_names].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end
  end
end