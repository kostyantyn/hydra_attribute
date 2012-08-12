module HydraAttribute
  class MissingAttributeInHydraSetError < NoMethodError
  end

  module HydraSetMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def hydra_sets
        @hydra_sets ||= HydraSet.where(entity_type: base_class.model_name)
      end

      def hydra_set(identifier)
        @hydra_set ||= {}
        @hydra_set[identifier] ||= hydra_sets.find do |hydra_set|
          hydra_set.id == identifier || hydra_set.name == identifier
        end
      end

      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_#{prefix}s
            @hydra_set_#{prefix}s ||= hydra_sets.map(&:#{prefix})
          end
        EOS
      end

      def clear_hydra_set_cache!
        @hydra_sets      = nil
        @hydra_set       = nil
        @hydra_set_ids   = nil
        @hydra_set_names = nil
      end
    end
  end
end