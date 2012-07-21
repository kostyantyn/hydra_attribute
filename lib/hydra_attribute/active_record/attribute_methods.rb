module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      NAME_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\z/
      CALL_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?]?\z/

      included do
        @hydra_attribute_methods_mutex = Mutex.new
      end

      module ClassMethods
        def hydra_attribute_methods_generated?
          @hydra_attribute_methods_generated ||= false
        end

        def generated_hydra_attribute_methods
          @generated_hydra_attribute_methods ||= begin
            mod = Module.new
            include mod
            mod
          end
        end

        def hydra_attributes
          @hydra_attributes ||= HydraAttribute.where(entity_type: base_class.model_name)
        end

        %w(id name backend_type).each do |prefix|
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def hydra_attribute_#{prefix}s
              @hydra_attribute_#{prefix}s ||= hydra_attributes.map(&:#{prefix}).uniq
            end
          EOS
        end

        def hydra_attribute(identifier)
          @hydra_attribute_cache ||= {}
          @hydra_attribute_cache[identifier] ||= hydra_attributes.find do |hydra_attribute|
            hydra_attribute.id == identifier || hydra_attribute.name == identifier
          end
        end

        def define_hydra_attribute_methods
          @hydra_attribute_methods_mutex.synchronize do
            return if hydra_attribute_methods_generated?
            hydra_attributes.each { |hydra_attribute| define_hydra_attribute_method(hydra_attribute) }
            @hydra_attribute_methods_generated = true
          end
        end

        def define_hydra_attribute_method(hydra_attribute)
          attribute_method_matchers.each do |matcher|
            current = matcher.method_name(hydra_attribute.name)
            target  = matcher.method_name(:value)

            if current =~ NAME_COMPILABLE_REGEXP
              defn = "def #{current}(*args)"
            else
              defn = "define_method(:'#{current}') do |*args|"
            end

            if target =~ CALL_COMPILABLE_REGEXP
              send = "#{target}(*args)"
            else
              send = "send(:'#{target}', *args)"
            end

            generated_hydra_attribute_methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
              #{defn}
                if value_model = hydra_value_model(#{hydra_attribute.id})
                  value_model.#{send}
                else
                  missing_attribute('#{hydra_attribute.name}', caller)
                end
              end
            EOS
          end
        end

        def reset_hydra_attribute_methods
          generated_hydra_attribute_methods.module_eval do
            instance_methods.each { |m| undef_method(m) }
          end

          @hydra_attributes                  = false
          @hydra_attribute_methods_generated = false
          @hydra_attribute_cache             = {}
        end

        def undefine_attribute_methods
          reset_hydra_attribute_methods
          super
        end
      end

      #def initialize(attributes = nil, options = {}, &block)
      #  super
      #  if attributes
      #    hydra_attributes = attributes.select { |name| self.class.hydra_attribute_names.include?(name.to_s) }
      #    attributes.delete_if { |name| self.class.hydra_attribute_names.include?(name.to_s) }
      #  else
      #    hydra_attributes = nil
      #  end
      #
      #  super(attributes, options) do
      #    self.class.hydra_attributes.each do |a|
      #      send("#{a.name}=", a.default_value)
      #    end
      #    assign_attributes(hydra_attributes)
      #    block.call(self) if block_given?
      #  end
      #end

      def respond_to?(name, include_private = false)
        self.class.define_hydra_attribute_methods unless self.class.hydra_attribute_methods_generated?
        super
      end

      %w(attributes attributes_before_type_cast).each do |method|
        class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method}
            self.class.hydra_attribute_backend_types.each_with_object(super) do |type, attributes|
              hydra_value_association(type).all_models.each do |model|
                hydra_attribute = self.class.hydra_attribute(model.hydra_attribute_id)
                attributes[hydra_attribute.name] = model.#{method}['value']
              end
            end
          end
        EOS
      end

      %w(read_attribute read_attribute_before_type_cast).each do |method|
        class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method}(attr_name)
            identifier = attr_name.to_s
            if self.class.hydra_attribute_names.include?(identifier)
              if value_model = hydra_value_model(identifier)
                value_model.#{method}('value')
              else
                missing_attribute(identifier, caller)
              end
            else
              super
            end
          end
        EOS
      end

      private

      def hydra_value_model(identifier)
        @hydra_value_model_cache ||= {}
        @hydra_value_model_cache[identifier] ||= begin
          hydra_attribute = self.class.hydra_attribute(identifier)
          association = hydra_value_association(hydra_attribute.backend_type)
          association.find_model_or_build(hydra_attribute_id: hydra_attribute.id)
        end
      end

      def hydra_value_association(backend_type)
        association(::HydraAttribute::AssociationBuilder.association_name(backend_type))
      end

      def method_missing(method, *args, &block)
        if self.class.hydra_attribute_methods_generated?
          super
        else
          self.class.define_hydra_attribute_methods
          if respond_to_without_attributes?(method)
            send(method, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end