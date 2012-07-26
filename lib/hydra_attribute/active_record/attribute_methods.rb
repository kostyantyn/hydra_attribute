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

        def grouped_hydra_attributes
          @grouped_hydra_attributes ||= hydra_attributes.group_by(&:backend_type)
        end

        %w(id name backend_type).each do |prefix|
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def hydra_attribute_#{prefix}s
              @hydra_attribute_#{prefix}s ||= hydra_attributes.map(&:#{prefix}).uniq
            end

            def grouped_hydra_attribute_#{prefix}s(type)
              instance = "@grouped_hydra_attribute_\#{type}_#{prefix}s"
              instance_variable_get(instance) || instance_variable_set(instance, grouped_hydra_attributes[type].map(&:#{prefix}).uniq)
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

          @hydra_attributes                  = nil
          @hydra_attribute_methods_generated = false
          @hydra_attribute_cache             = {}
          @grouped_hydra_attributes          = nil

          %w(id name backend_type).each do |prefix|
            instance_variable_set("@hydra_attribute_#{prefix}s", nil)

            SUPPORT_TYPES.each do |type|
              instance_variable_set("@grouped_hydra_attribute_#{type}_#{prefix}s", nil)
            end
          end
        end

        def undefine_attribute_methods
          reset_hydra_attribute_methods
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
        super
      end

      def attributes
        hydra_value_models.each_with_object(super) do |model, attributes|
          attributes[model.attribute_name] = model.read_attribute('value')
        end
      end

      def attributes_before_type_cast
        hydra_value_models.each_with_object(super) do |model, attributes|
          attributes[model.attribute_name] = model.read_attribute_before_type_cast('value')
        end
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

      def hydra_attribute_names
        @hydra_attribute_names ||= hydra_value_models.map(&:attribute_name)
      end

      def hydra_attribute_backend_types
        @hydra_attribute_backend_types ||= self.class.hydra_attribute_backend_types.select do |backend_type|
          hydra_value_association(backend_type).all_models.any?
        end
      end

      def inspect
        attrs  = self.class.column_names.map { |name| "#{name}: #{attribute_for_inspect(name)}" }
        attrs += hydra_value_models.map { |model| "#{model.attribute_name}: #{model.attribute_for_inspect('value')}" }
        "#<#{self.class} #{attrs.join(', ')}>"
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

      def hydra_value_models
        @hydra_value_models ||= self.class.hydra_attribute_backend_types.inject([]) do |models, backend_type|
          models + hydra_value_association(backend_type).all_models
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