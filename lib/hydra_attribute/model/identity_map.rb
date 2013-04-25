module HydraAttribute
  module Model

    # @see HydraAttribute::Model::IdentityMap::ClassMethods ClassMethods for documentation
    module IdentityMap
      extend ActiveSupport::Concern

      module ClassMethods
        # Identity map key
        #
        # @return [Symbol]
        def identity_map_cache_key
          @identity_map_cache_key ||= name.underscore.to_sym
        end

        # Identity map
        #
        # @return [HydraAttribute::IdentityMap]
        def identity_map
          ::HydraAttribute.cache(identity_map_cache_key) { ::HydraAttribute::IdentityMap.new }
        end

        # Returns identity map object which is inserted into the default one
        #
        # @param [Symbol] cache_key
        # @return [HydraAttribute::IdentityMap]
        def nested_identity_map(cache_key)
          identity_map.cache(cache_key) { ::HydraAttribute::IdentityMap.new }
        end

        # Proxy method to +identity_map+
        #
        # @param [String, Symbol] key
        # @param [NilClass, Object] value
        # @yield
        # @return [Object]
        def cache(key, value = nil, &block)
          identity_map.cache(key, value, &block)
        end

        # Registers nested cache
        #
        # @param [Array<Symbol>] cache_keys
        # @return [NilClass]
        def register_nested_cache(*cache_keys)
          cache_keys.each do |cache_key|
            nested_cache_keys << cache_key
          end
        end

        private
          # Store all nested cache keys
          def nested_cache_keys
            @nested_cache_keys ||= []
          end
      end
    end
  end
end