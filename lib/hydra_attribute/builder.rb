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
      update_mass_assignment_security
    end

    private
      def build_associations
        SUPPORTED_BACKEND_TYPES.each do |type|
          AssociationBuilder.build(klass, type)
        end
      end

      def update_mass_assignment_security
        klass.hydra_attributes.each(&:update_mass_assignment_security)
      end
  end
end