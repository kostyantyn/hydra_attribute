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

        # Proxy method to +identity_map+
        #
        # @param [String, Symbol] key
        # @param [NilClass, Object] value
        # @yield
        # @return [Object]
        def cache(key, value = nil, &block)
          indentity_map.cache(key, value, &block)
        end
      end
    end
  end
end