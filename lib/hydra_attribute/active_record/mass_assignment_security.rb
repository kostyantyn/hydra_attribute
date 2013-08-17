module HydraAttribute
  module ActiveRecord
    module MassAssignmentSecurity

      class PermissionSet
        def initialize(entity, authorizer)
          @entity     = entity
          @authorizer = authorizer
        end

        def deny?(attribute_name)
          hydra_attribute = hydra_attribute_by_name(attribute_name)
          hydra_attribute ? !hydra_attribute.white_list : @authorizer.deny?(attribute_name)
        end

        private
          def respond_to_missing?(method, include_private)
            @authorizer.respond_to?(method, include_private)
          end

          def method_missing(method, *args, &block)
            @authorizer.send(method, *args, &block)
          end

          # TODO should be optimized. List of allowed attributes should be cached
          def hydra_attribute_by_name(attribute_name)
            ::HydraAttribute::HydraAttribute.all_by_entity_type(@entity.class.name).find do |attribute|
              attribute.name == attribute_name
            end
          end
      end

      protected
        def mass_assignment_authorizer(role)
          PermissionSet.new(self, super(role))
        end
    end
  end
end