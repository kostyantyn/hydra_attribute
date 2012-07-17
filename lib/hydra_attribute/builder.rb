module HydraAttribute
  class Builder
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @klass.send :include, ActiveRecord::Scoping
      @klass.send :include, ActiveRecord::AttributeMethods
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