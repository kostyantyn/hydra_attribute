module HydraAttribute
  class Builder
    attr_reader :klass

    def initialize(klass)
      @klass = klass
      @klass.send :include, ActiveRecord::Scoping
      @klass.send :include, ActiveRecord::AttributeMethods
    end

    def self.build(klass)
      new(klass).build
    end

    def build
      SUPPORT_TYPES.each do |type|
        AssociationBuilder.build(klass, type)
      end

      build_callbacks
    end

    def build_callbacks
      klass.class_eval <<-EOS, __FILE__, __LINE__ + 1
        after_create   :create_hydra_values
        after_update   :update_hydra_values
        before_destroy :destroy_hydra_values
        after_commit   :hydra_touch

        private

        def create_hydra_values
          all_hydra_models do |model|
            model.entity_id = id
            model.save
          end
        end

        def update_hydra_values
          all_hydra_models do |model|
            model.entity_id = id # ????
            model.save
          end
        end

        def destroy_hydra_values
          all_hydra_models do |model|
            model.destroy
          end
        end

        def all_hydra_models(&block)
          self.class.hydra_attribute_backend_types.each do |type|
            association(AssociationBuilder.association_name(type)).all_models.each(&block)
          end
        end

        def hydra_touch
          touch
        end
      EOS
    end

  end
end