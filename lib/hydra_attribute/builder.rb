module HydraAttribute
  class Builder
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @klass.class_eval do
        include ActiveRecord::Scoping
        include AttributeHelpers
      end
    end

    SUPPORT_TYPES.each do |type|
      define_method(type) do |*attributes|
        Association.new(klass, type).build


        attributes.each do |attribute|
          Attribute.new(klass, attribute, type).build
        end
      end
    end
  end
end