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
      SUPPORTED_BACKEND_TYPES.each do |type|
        AssociationBuilder.build(klass, type)
      end
    end

    def build_white_list
      klass.hydra_attributes.each(&:toggle_white_list!)
    end
  end
end