module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      module BeforeTypeCast
        extend ActiveSupport::Concern
        extend AttributeProxy

        use_proxy_to_hydra_attribute :read_attribute_before_type_cast

        def attributes_before_type_cast
          super.merge(hydra_attributes_before_type_cast)
        end
      end
    end
  end
end