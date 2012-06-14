module HydraAttribute
  class Builder
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @klass.class_eval do
        include ActiveRecord::Scoping
        include ActiveRecord::AttributeMethods
      end
    end

    def build
      SUPPORT_TYPES.each do |type|
        AssociationBuilder.new(klass, type).build
      end
    end

  end
end