module HydraAttribute
  class Builder
    attr_reader :klass

    def initialize(klass)
      [
        ActiveRecord::Scoping,
        ActiveRecord::AttributeMethods,
        EntityCallbacks
      ].each do |m|
        klass.send :include, m
      end

      @klass = klass
    end

    def self.build(klass)
      new(klass).build
    end

    def build
      build_associations
      build_white_list
    end

    private

    def build_associations
      SUPPORT_TYPES.each do |type|
        AssociationBuilder.build(klass, type)
      end
    end

    def build_white_list
      klass.hydra_attributes.each do |hydra_attribute|
        klass.accessible_attributes.add(hydra_attribute.name) if hydra_attribute.white_list?
      end
    end
  end
end