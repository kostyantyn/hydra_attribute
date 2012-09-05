module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      include HydraMethods

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
                if hydra_set_id? and self.class.hydra_set_attribute_ids(hydra_set_id).exclude?(#{hydra_attribute.id})
                  raise MissingAttributeInHydraSetError, %(Hydra attribute "#{hydra_attribute.name}" does not exist in hydra set "\#{self.class.hydra_set(hydra_set_id).name}")
                end

                if value_model = hydra_value_model(#{hydra_attribute.id})
                  value_model.#{send}
                else
                  missing_attribute('#{hydra_attribute.name}', caller)
                end
              end
            EOS
          end
        end

        def reset_hydra_attribute_methods!
          generated_hydra_attribute_methods.module_eval do
            instance_methods.each { |m| undef_method(m) }
          end
          @hydra_attribute_methods_generated = false

          clear_hydra_method_cache!
        end

        def undefine_attribute_methods
          reset_hydra_attribute_methods!
          super
        end

        def inspect
          attr_list  = columns.map { |c| "#{c.name}: #{c.type}" }
          attr_list += hydra_attributes.map { |a| "#{a.name}: #{a.backend_type}" }
          "#{name}(#{attr_list.join(', ')})"
        end
      end

      def respond_to?(name, include_private = false)
        self.class.define_hydra_attribute_methods unless self.class.hydra_attribute_methods_generated?

        # @COMPATIBILITY with 3.1.x active_model doesn't have "attribute_method_matcher" method
        if ::ActiveRecord::VERSION::STRING.start_with?('3.1.')
          matchers  = attribute_method_matchers.partition { |m| m.prefix.empty? && m.suffix.empty? }.reverse.flatten(1)
          matcher   = matchers.detect { |method| method.match(name) }
          attr_name = matcher.match(name).attr_name
        else
          attr_name = self.class.send(:attribute_method_matcher, name).attr_name
        end

        if hydra_attribute?(attr_name)
          self.class.hydra_set_attribute_names(hydra_set_id).include?(attr_name)
        else
          super
        end
      end

      def attributes
        hydra_value_models.each_with_object(super) do |model, attributes|
          attributes[model.hydra_attribute_name] = model.read_attribute('value')
        end
      end

      def attributes_before_type_cast
        hydra_value_models.each_with_object(super) do |model, attributes|
          attributes[model.hydra_attribute_name] = model.read_attribute_before_type_cast('value')
        end
      end

      %w(read_attribute read_attribute_before_type_cast).each do |method|
        class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{method}(attr_name)
            identifier = attr_name.to_s
            if self.class.hydra_set_attribute_names(hydra_set_id).include?(identifier)
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

      def inspect
        attrs = hydra_value_models.map { |model| "#{model.hydra_attribute_name}: #{model.attribute_for_inspect('value')}" }
        super.gsub(/>$/, ", #{attrs.join(', ')}>")
      end

      private
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