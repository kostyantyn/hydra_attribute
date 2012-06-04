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

    SUPPORT_TYPES.each do |type|
      class_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{type}(*attributes)
          AssociationBuilder.new(klass, :#{type}).build

          attributes.each do |attribute|
            AttributeBuilder.new(klass, attribute, :#{type}).build
          end
        end
      EOS
    end
  end
end