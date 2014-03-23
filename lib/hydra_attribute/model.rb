require 'active_record/errors'
require 'hydra_attribute/model/validations'
require 'hydra_attribute/model/persistence'
require 'hydra_attribute/model/mediator'
require 'hydra_attribute/model/notifiable'
require 'hydra_attribute/model/identity_map'
require 'hydra_attribute/model/cacheable'
require 'hydra_attribute/model/dirty'
require 'hydra_attribute/model/has_many_through'

module HydraAttribute
  module Model
    extend ActiveSupport::Concern

    include Validations
    include Persistence
    include Mediator
    include Notifiable
    include IdentityMap
    include Cacheable
    include Dirty
    include HasManyThrough

    included do
      # Compatibility with Rails' helpers
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      include ActiveModel::Conversion
    end

    module ClassMethods
      # Find first model
      #
      # @return [HydraAttribute::Model]
      def first
        all.first
      end

      # Find last model
      #
      # @return [HydraAttribute::Model]
      def last
        all.last
      end

      # Returns number of models
      #
      # @return [Fixnum]
      def count
        all.count
      end
    end
  end
end
