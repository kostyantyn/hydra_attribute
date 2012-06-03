module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      module Read
        extend ActiveSupport::Concern
        extend AttributeProxy

        use_proxy_to_hydra_attribute :read_attribute

      end
    end
  end
end