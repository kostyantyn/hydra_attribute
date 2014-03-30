module HydraAttribute
  module ActiveRecord
    module Associations
      extend ActiveSupport::Concern

      def association(*)
        association = super
        if association.klass.include?(::HydraAttribute::ActiveRecord)
          association.singleton_class.send(:include, ::HydraAttribute::ActiveRecord::Associations::Association)
        end
        association
      end
    end
  end
end

require 'hydra_attribute/active_record/associations/association'
