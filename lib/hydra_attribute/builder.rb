module HydraAttribute
  class Builder
    def initialize(klass)
      @klass = klass
      @klass.base_class.extend(Scoped) unless @klass.base_class.singleton_class.include?(Scoped)
    end

    SUPPORT_TYPES.each do |type|
      define_method(type) do |*attributes|
        Association.new(@klass, type).build


        attributes.each do |attribute|
          Attribute.new(@klass, attribute, type).build
        end
      end
    end
  end
end