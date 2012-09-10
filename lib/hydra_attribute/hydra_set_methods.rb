module HydraAttribute
  # This error is raised when called method for attribute which doesn't exist in current hydra set
  #
  # @example
  #   Product.hydra_attributes.create(name: 'price', backend_type: 'float')
  #   Product.hydra_attributes.create(name: 'title', backend_type: 'string')
  #
  #   hydra_set = Product.hydra_sets.create(name: 'Default')
  #   hydra_set.hydra_attributes = [Product.hydra_attribute('title')]
  #
  #   product = Product.new(hydra_set_id: hydra_set.id)
  #   product.title = 'Toy' # ok
  #   product.price = 2.50  # raise HydraAttribute::MissingAttributeInHydraSetError
  class MissingAttributeInHydraSetError < NoMethodError
  end

  # @see HydraAttribute::HydraSetMethods::ClassMethods ClassMethods for documentation
  module HydraSetMethods
    extend ActiveSupport::Concern

    module ClassMethods
      extend Memoizable

      # Returns attribute sets for current entity.
      #
      # @note This method is cacheable, therefore just one request to database is used
      # @example
      #   Product.hydra_sets                         # [<HydraAttribute::HydraSet>, ...]
      #   Product.hydra_sets.create(name: 'Default') # create attribute set
      #   Product.hydra_sets.each(&:destroy)         # remove all attribute sets
      # @return [ActiveRecord::Relation] contains preloaded attribute sets
      def hydra_sets
        HydraSet.where(entity_type: base_class.model_name)
      end
      hydra_memoize :hydra_sets

      # Finds attribute set by name or id
      #
      # @note This method is cacheable, therefore it's better to use it instead of manually searching.
      # @example
      #   Product.hydra_set(10)        # or
      #   Product.hydra_set('Default')
      # @param identifier [Fixnum, String] id or name of attribute set
      # @return [HydraAttribute::HydraSet, NilClass] attribute set model or +nil+
      def hydra_set(identifier)
        hydra_sets.find do |hydra_set|
          hydra_set.id == identifier || hydra_set.name == identifier
        end
      end
      hydra_memoize :hydra_set

      # @!method hydra_set_ids
      # Returns all attribute set ids
      #
      # @note This method is cacheable.
      # @example
      #   Product.hydra_sets.create(name: 'First')  # 1
      #   Product.hydra_sets.create(name: 'Second') # 2
      #   Product.hydra_set_ids                     # [1, 2]
      # @return [Array<Fixnum>] contains attribute set ids

      # @!method hydra_set_names
      # Returns all attribute set names
      #
      # @note This method is cacheable.
      # @example
      #   Product.hydra_sets.create(name: 'First')  # 1
      #   Product.hydra_sets.create(name: 'Second') # 2
      #   Product.hydra_set_names                   # ["First", "Second"]
      # @return [Array<Fixnum>] contains attribute set names
      %w(id name).each do |prefix|
        module_eval <<-EOS, __FILE__, __LINE__ + 1
          def hydra_set_#{prefix}s
            hydra_sets.map(&:#{prefix})
          end
          hydra_memoize :hydra_set_#{prefix}s
        EOS
      end

      # Clear cache for the following methods:
      # * hydra_sets
      # * hydra_set(identifier)
      # * hydra_set_ids
      # * hydra_set_names
      #
      # @note This method should not be called manually. It used for hydra_attribute gem engine.
      # @return [NilClass]
      def clear_hydra_set_cache!
        [:@hydra_sets, :@hydra_set, :@hydra_set_ids, :@hydra_set_names].each do |variable|
          remove_instance_variable(variable) if instance_variable_defined?(variable)
        end
      end
    end
  end
end