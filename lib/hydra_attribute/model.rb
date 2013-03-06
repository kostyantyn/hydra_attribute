require 'active_record/errors'
require 'hydra_attribute/model/validations'
require 'hydra_attribute/model/persistence'
require 'hydra_attribute/model/mediator'
require 'hydra_attribute/model/notifiable'
require 'hydra_attribute/model/identity_map'
require 'hydra_attribute/model/cacheable'
require 'hydra_attribute/model/dirty'

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
  end
end