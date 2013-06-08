require 'hydra_attribute/active_record/attribute_methods'
require 'hydra_attribute/active_record/migration'
require 'hydra_attribute/active_record/relation'
require 'hydra_attribute/active_record/scoping'

module HydraAttribute
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      unless ancestors.include?(::ActiveRecord::Base)
        raise %(Cannot include HydraAttribute::ActiveRecord module because "#{self}" is not inherited from ActiveRecord::Base)
      end

      unless base_class.equal?(self)
        raise %(HydraAttribute::ActiveRecord module should be included to the base class "#{base_class}" instead of "#{self}")
      end
    end

    include ::HydraAttribute::HydraEntity
    include ::HydraAttribute::ActiveRecord::Scoping
    include ::HydraAttribute::ActiveRecord::AttributeMethods
  end
end