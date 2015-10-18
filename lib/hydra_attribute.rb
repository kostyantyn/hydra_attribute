require 'active_record'

module HydraAttribute
  SUPPORTED_BACKEND_TYPES = %w[string text integer float decimal boolean datetime].freeze

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
require 'hydra_attribute/migrator'
require 'hydra_attribute/identity_map'
require 'hydra_attribute/model'
require 'hydra_attribute/hydra_attribute'
require 'hydra_attribute/hydra_set'
require 'hydra_attribute/hydra_attribute_set'
require 'hydra_attribute/hydra_value'
require 'hydra_attribute/hydra_entity'
require 'hydra_attribute/hydra_entity_attribute_association'
require 'hydra_attribute/active_record'

require 'hydra_attribute/monkey_patch' if ActiveRecord.version >= Gem::Version.new('4.2.0')

require 'hydra_attribute/railtie' if defined?(Rails)
