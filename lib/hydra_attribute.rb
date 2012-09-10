module HydraAttribute
  SUPPORTED_BACKEND_TYPES = %w(string text integer float boolean datetime).freeze

  class << self
    def config
      @config ||= Configuration.new
    end

    def setup
      yield config
    end
  end

end

require 'hydra_attribute/version'
require 'hydra_attribute/configuration'
require 'hydra_attribute/association_builder'
require 'hydra_attribute/builder'
require 'hydra_attribute/migrator'
require 'hydra_attribute/memoizable'
require 'hydra_attribute/hydra_attribute'
require 'hydra_attribute/hydra_set'
require 'hydra_attribute/entity_callbacks'
require 'hydra_attribute/hydra_set_methods'
require 'hydra_attribute/hydra_value_methods'
require 'hydra_attribute/hydra_attribute_methods'
require 'hydra_attribute/hydra_methods'
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
