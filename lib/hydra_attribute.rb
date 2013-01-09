module HydraAttribute
  SUPPORTED_BACKEND_TYPES = %w(string text integer float boolean datetime).freeze

  class << self
    def config
      @config ||= Configuration.new
    end

    def setup
      yield config
    end

    def identity_map
      Thread.current[:hydra_attribute] ||= IdentityMap.new
    end

    def cache(key, value = nil, &block)
      identity_map.cache(key, value, &block)
    end
  end

end

require 'hydra_attribute/version'
require 'hydra_attribute/configuration'
require 'hydra_attribute/association_builder'
require 'hydra_attribute/builder'
require 'hydra_attribute/migrator'
require 'hydra_attribute/identity_map'
require 'hydra_attribute/memoizable'
require 'hydra_attribute/model'
require 'hydra_attribute/hydra_attribute'
require 'hydra_attribute/hydra_set'
require 'hydra_attribute/hydra_value'
require 'hydra_attribute/hydra_entity'
require 'hydra_attribute/active_record'
require 'hydra_attribute/active_record/scoping'
require 'hydra_attribute/active_record/reflection'
require 'hydra_attribute/active_record/association'
require 'hydra_attribute/active_record/association_preloader'
require 'hydra_attribute/active_record/migration'
require 'hydra_attribute/active_record/relation'
require 'hydra_attribute/active_record/relation/query_methods'
require 'hydra_attribute/active_record/attribute_methods'

require 'hydra_attribute/railtie' if defined?(Rails)
