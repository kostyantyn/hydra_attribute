module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern
      include AttributeHelpers

      included do
        include Read
        include BeforeTypeCast
      end

      def attributes
        super.merge(hydra_attributes)
      end
    end
  end
end