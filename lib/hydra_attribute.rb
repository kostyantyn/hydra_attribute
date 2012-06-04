module HydraAttribute
  SUPPORT_TYPES = [:string, :text, :integer, :float, :boolean, :datetime]

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
require 'hydra_attribute/attribute_builder'
require 'hydra_attribute/builder'
require 'hydra_attribute/migration'
require 'hydra_attribute/attribute_helpers'
require 'hydra_attribute/attribute_proxy'
require 'hydra_attribute/active_record'
require 'hydra_attribute/active_record/scoping'
require 'hydra_attribute/active_record/relation'
require 'hydra_attribute/active_record/relation/query_methods'
require 'hydra_attribute/active_record/attribute_methods'
require 'hydra_attribute/active_record/attribute_methods/read'
require 'hydra_attribute/active_record/attribute_methods/before_type_cast'

require 'hydra_attribute/railtie' if defined?(Rails)
