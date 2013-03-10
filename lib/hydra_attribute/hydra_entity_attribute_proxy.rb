module HydraAttribute
  class HydraEntityAttributeProxy
    class << self
      attr_accessor :entity_class

      # Checks if attribute methods were generated
      #
      # @return [TrueClass, FalseClass]
      def method_generated?
        @method_generated ||= false
      end

      # Generate all attribute methods
      #
      # @return [TrueClass]
      def generate_methods
        ::HydraAttribute::HydraAttribute.all_by_entity_type(entity_class.model_name).each do |hydra_attribute|
          generate_method(hydra_attribute)
        end
        @method_generated = true
      end

      # Generate method for +hydra_attribute+
      #
      # @param [HydraAttribute::HydraAttribute]
      # @return [NilClass]
      def generate_method(hydra_attribute)
        entity_class.attribute_method_matchers.each do |matcher|
          current = matcher.method_name(hydra_attribute.name)
          proxy   = matcher.method_name(:value)

          if current =~ ActiveModel::AttributeMethods::NAME_COMPILABLE_REGEXP
            source = "def #{current}(*args)"
          else
            source = "define_method(:'#{current}') do |*args|"
          end

          if proxy =~ ActiveModel::AttributeMethods::CALL_COMPILABLE_REGEXP
            target = "#{proxy}(*args)"
          else
            target = "send(:'#{proxy}', *args)"
          end

          class_eval <<-EOS, __FILE__, __LINE__ + 1
            #{source}
              entity.hydra_attribute_value_association.hydra_value_by_hydra_attribute_id(#{hydra_attribute.id}).#{target}
            end
          EOS
        end
      end

      # Returns class name
      #
      # @return [String]
      def inspect
        "#{entity_class.model_name}HydraAttributeProxy"
      end
    end

    attr_reader :entity

    # Initializer
    #
    # @param [ActiveRecord::Base] entity
    def initialize(entity)
      @entity = entity
    end

    # Returns object name
    #
    # @return [String]
    def inspect
      "#{self.class.inspect}#{entity.inspect}"
    end

    def respond_to?(method, include_private = false)
      self.class.generate_methods unless self.class.method_generated?
      super
    end

    private
      def method_missing(method, *args, &block)
        self.class.generate_methods unless self.class.method_generated?
        if respond_to?(method)
          send(method, *args, &block)
        else
          super
        end
      end
  end
end