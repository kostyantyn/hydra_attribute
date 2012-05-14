module HydraAttribute
  class Association

    def initialize(klass, type)
      @klass, @type = klass, type
    end

    def build
      create_associated_model
      add_association_for_class
    end

    private

    def create_associated_model
      const = config.associated_const_name(@type)
      unless namespace.const_defined?(const)
        klass = namespace.const_set(const, Class.new(::ActiveRecord::Base))
        klass.table_name = config.table_name(@type)
        klass.belongs_to :entity, polymorphic: true, touch: true, autosave: true
      end
    end

    def add_association_for_class
      assoc = config.association(@type)
      unless @klass.reflect_on_association(assoc)
        @klass.has_many assoc, as: :entity, class_name: config.associated_model_name(@type), autosave: true
      end
    end

    def config
      HydraAttribute.config
    end

    def namespace
      config.use_module_for_associated_models ? HydraAttribute : Object
    end
  end
end