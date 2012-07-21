module HydraAttribute
  class AssociationBuilder
    attr_reader :klass, :type

    def initialize(klass, type)
      @klass, @type = klass, type
    end

    class << self
      def build(klass, type)
        new(klass, type).build
      end

      def model_name(klass, type)
        "Hydra#{type.to_s.capitalize}#{klass.model_name}"
      end

      def class_name(klass, type)
        "::HydraAttribute::#{model_name(klass, type)}"
      end

      def table_name(klass, type)
        "hydra_#{type}_#{klass.table_name}"
      end

      def association_name(type)
        "hydra_#{type}_values".to_sym
      end
    end

    def build
      create_value_model
      add_association
    end

    def create_value_model
      value_model = ::HydraAttribute.const_set(model_name, Class.new(::ActiveRecord::Base))
      value_model.table_name = table_name
      value_model.belongs_to :entity, class_name: klass.model_name, autosave: false
      value_model.belongs_to :hydra_attribute, class_name: 'HydraAttribute::HydraAttribute'
      value_model.attr_accessible :hydra_attribute_id, :value
    end

    def add_association
      klass.has_many association_name, class_name: class_name, foreign_key: :entity_id, dependent: :delete_all, autosave: false
    end

    def model_name
      self.class.model_name(klass, type)
    end

    def class_name
      self.class.class_name(klass, type)
    end

    def table_name
      self.class.table_name(klass, type)
    end

    def association_name
      self.class.association_name(type)
    end
  end
end