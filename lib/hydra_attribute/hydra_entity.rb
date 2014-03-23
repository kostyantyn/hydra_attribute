module HydraAttribute
  module HydraEntity
    class RelationDecorator
      def initialize(entity_type, model_class)
        @entity_type = entity_type
        @model_class = model_class
      end

      def create(attributes = {})
        @model_class.create(attributes.merge(entity_type: @entity_type))
      end

      def build(attributes = {})
        @model_class.new(attributes.merge(entity_type: @entity_type))
      end

      private
        def respond_to_missing?(symbol, include_private)
          _models.respond_to?(symbol, include_private)
        end

        def method_missing(method, *args, &block)
          _models.send(method, *args, &block)
        end

        def _models
          @model_class.all_by_entity_type(@entity_type)
        end
    end

    extend ActiveSupport::Concern

    included do
      after_save    :save_hydra_attributes
      after_destroy :destroy_hydra_attributes
    end

    module ClassMethods
      # Returns collection of hydra attributes for current entity
      #
      # @return [HydraAttribute::HydraEntity::RelationDecorator]
      def hydra_attributes
        @hydra_attributes ||= RelationDecorator.new(name, ::HydraAttribute::HydraAttribute)
      end

      # Returns collection of hydra sets for current entity
      #
      # @return [HydraAttribute::HydraEntity::RelationDecorator]
      def hydra_sets
        @hydra_sets ||= RelationDecorator.new(name, ::HydraAttribute::HydraSet)
      end
    end

    # Returns association between hydra attributes and their values
    #
    # @return [HydraAttribute::HydraEntityAttributeAssociation]
    def hydra_attribute_association
      @hydra_attribute_association ||= HydraEntityAttributeAssociation.new(self)
    end

    # Sets association object which connects hydra attributes with their values
    #
    # @param [HydraAttribute::HydraEntityAttributeAssociation]
    def hydra_attribute_association=(association)
      @hydra_attribute_association = association
    end

    # Return +HydraSet+ object if it exists
    #
    # @return [HydraAttribute::HydraSet]
    def hydra_set
      HydraSet.find(hydra_set_id) if hydra_set_id
    end

    # Returns hydra attribute names with theirs values
    #
    # @return [Hash]
    def hydra_attributes
      hydra_attribute_association.hydra_attributes
    end

    # Returns hydra attribute names with theirs values before type casting
    #
    # @return [Hash]
    def hydra_attributes_before_type_cast
      hydra_attribute_association.hydra_attributes_before_type_cast
    end

    def respond_to?(method, include_private = false)
      hydra_attribute_association.has_proxy_method?(method) || super
    end

    private
      def save_hydra_attributes
        hydra_attribute_association.save
      end

      def destroy_hydra_attributes
        hydra_attribute_association.destroy
      end

      def method_missing(method, *args, &block)
        hydra_attribute_association.delegate(method, *args, &block)
      rescue HydraSet::MissingAttributeInHydraSetError, HydraEntityAttributeAssociation::AttributeWasNotSelectedError
        raise
      rescue
        super
      end
  end
end
