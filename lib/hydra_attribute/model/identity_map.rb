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
          identity_map.cache(key, value, &block)
        end

        # Generates nested cache keys
        #
        # @param [Array<Symbol>] cache_keys
        # @return [NilClass]
        def nested_cache_keys(*cache_keys)
          cache_keys.each do |cache_key|
            instance_eval <<-EOS, __FILE__, __LINE__ + 1
              def #{cache_key}_identity_map                                             # def name_identity_map
                identity_map.cache(:#{cache_key}) { ::HydraAttribute::IdentityMap.new } #   identity_map(:name) { ::HydraAttribute::identityMap.new }
              end                                                                       # end

              def #{cache_key}_cache(key, value = nil, &block)                          # def name_cache(key, value = nil, &block)
                #{cache_key}_identity_map.cache(key, value, &block)                     #   name_identity_map.cache(key, value, &block)
              end                                                                       # end
            EOS
          end
        end
      end
    end
  end
end