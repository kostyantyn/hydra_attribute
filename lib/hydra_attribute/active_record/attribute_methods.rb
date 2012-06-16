module HydraAttribute
  module ActiveRecord
    module AttributeMethods
      extend ActiveSupport::Concern

      NAME_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?=]?\z/
      CALL_COMPILABLE_REGEXP = /\A[a-zA-Z_]\w*[!?]?\z/

      included do
        @hydra_attribute_methods_mutex = Mutex.new

        include Read
        include BeforeTypeCast
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
          @hydra_attributes ||= HydraAttribute.where(entity_type: base_class.model_name).map(&:attributes)
        end

        def hydra_attribute_ids
          hydra_attributes.map { |hydra_attribute| hydra_attribute['id'] }
        end


        def hydra_attribute_names
          hydra_attributes.map { |hydra_attribute| hydra_attribute['name'] }
        end

        def hydra_attribute_types
          hydra_attributes.map { |hydra_attribute| hydra_attribute['backend_type'] }.uniq
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
            current = matcher.method_name(hydra_attribute['name'])
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

            body = "hydra_value_model(#{hydra_attribute['id']}, '#{hydra_attribute['backend_type']}').#{send}"

            generated_hydra_attribute_methods.module_eval <<-EOS, __FILE__, __LINE__ + 1
              #{defn}
                #{body}
              end
            EOS
          end
        end
      end

      def hydra_value_model(hydra_attribute_id, type)
        collection = send(::HydraAttribute::AssociationBuilder.new(self.class, type).table_name)
        collection.detect { |model| model.hydra_attribute_id == hydra_attribute_id } || collection.build(hydra_attribute_id: hydra_attribute_id)
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

      #def initialize(attributes = nil, options = {})
      #  @hydra_attributes = self.class.hydra_attributes
      #  super
      #end
      #
      #def init_with(coder)
      #  @hydra_attribute_names = self.class.hydra_attributes
      #  super
      #end
      #
      #def initialize_dup(other)
      #  if other.instance_variable_defined?(:@hydra_attribute_names)
      #    @hydra_attribute_names = other.instance_variable_get(:@hydra_attribute_names)
      #  else
      #    @hydra_attribute_names = self.class.hydra_attribute_names
      #  end
      #  super
      #end
      #
      #def hydra_attribute_model(name, type)
      #  collection = send(HydraAttribute.config.association(type))
      #  collection.detect { |model| model.name == name } || collection.build(name: name)
      #end
      #
      #def attributes
      #  super.merge(hydra_attributes)
      #end
      #
      #%w(attributes attributes_before_type_cast).each do |attr_method|
      #  module_eval <<-EOS, __FILE__, __LINE__ + 1
      #    def hydra_#{attr_method}
      #      @hydra_attribute_names.each_with_object({}) do |name, attributes|
      #        type = self.class.hydra_attributes[name]
      #        attributes[name] = hydra_attribute_model(name, type).#{attr_method}['value']
      #      end
      #    end
      #  EOS
      #end
    end
  end
end