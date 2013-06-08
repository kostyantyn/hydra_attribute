module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      def attributes
        super.merge(hydra_attributes)
      end
    end
  end
end