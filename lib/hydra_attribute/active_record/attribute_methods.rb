module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      def attributes
        super.merge(hydra_attributes)
      end

      def read_attribute(name)
        name = name.to_s
        if hydra_attributes.has_key?(name)
          hydra_attributes[name]
        else
          super
        end
      end
    end
  end
end