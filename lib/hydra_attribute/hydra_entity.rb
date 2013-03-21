module HydraAttribute
  module HydraEntity
    extend ActiveSupport::Concern

    included do
      after_save :save_hydra_attributes
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

    def respond_to?(method, include_private = false)
      hydra_attribute_association.has_proxy_method?(method) || super
    end

    private
      def save_hydra_attributes
        hydra_attribute_association.save
      end

      def method_missing(method, *args, &block)
        hydra_attribute_association.delegate(method, *args, &block)
      rescue HydraSet::MissingAttributeInHydraSetError
        raise
      rescue
        super
      end
  end
end