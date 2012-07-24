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
      SUPPORT_TYPES.each do |type|
        AssociationBuilder.build(klass, type)
      end
    end
  end
end