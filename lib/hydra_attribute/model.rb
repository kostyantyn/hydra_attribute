require 'active_record/errors'
require 'hydra_attribute/model/identity_map'
require 'hydra_attribute/model/mediator'
require 'hydra_attribute/model/validations'
require 'hydra_attribute/model/persistence'
require 'hydra_attribute/model/cache'

module HydraAttribute
  module Model
    extend ActiveSupport::Concern

    include IdentityMap
    include Mediator
    include Validations
    include Persistence
    include Cache
  end
end