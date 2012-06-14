module HydraAttribute
  class AssociationBuilder

    attr_reader :klass, :type

    def initialize(klass, type)
      @klass, @type = klass, type
    end

    def build
      create_value_model
      add_association
    end

    private

    def create_value_model
      value_model = ::HydraAttribute.const_set(model_name, Class.new(::ActiveRecord::Base))
      value_model.table_name = table_name
      value_model.belongs_to :entity, class_name: klass.model_name, touch: true, autosave: true
      value_model.belongs_to :hydra_attribute, class_name: 'HydraAttribute::HydraAttribute'
      value_model.attr_accessible :hydra_attribute_id, :value
    end

    def add_association
      klass.has_many table_name, class_name: class_name, foreign_key: :entity_id, autosave: true, dependent: :delete_all
    end

    def model_name
      "Hydra#{klass.model_name}#{type.to_s.titleize}Value"
    end

    def class_name
      "::HydraAttribute::#{model_name}"
    end

    def table_name
      "hydra_#{klass.table_name.singularize}_#{type}_values"
    end
  end
end