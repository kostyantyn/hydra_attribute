require 'hydra_attribute/active_record/attribute_methods'
require 'hydra_attribute/active_record/migration'
require 'hydra_attribute/active_record/relation'
require 'hydra_attribute/active_record/associations'

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
    include ::HydraAttribute::ActiveRecord::AttributeMethods
    include ::HydraAttribute::ActiveRecord::Associations

    module ClassMethods
      def inspect
        if hydra_attributes.any?
          inspection = hydra_attributes.map do |hydra_attribute|
            "#{hydra_attribute.name}: #{hydra_attribute.backend_type}"
          end
          super.sub(/\)$/, ", #{inspection.join(', ')})")
        else
          super
        end
      end

      private
        def relation
          relation = super
          relation.singleton_class.send(:include, ::HydraAttribute::ActiveRecord::Relation)
          relation
        end
    end

    def inspect
      if hydra_attributes.any?
        inspection = hydra_attributes.keys.map do |name|
          "#{name}: #{attribute_for_inspect(name)}"
        end
        super.sub(/>$/, ", #{inspection.join(', ')}>")
      else
        super
      end
    end
  end
end
