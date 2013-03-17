module HydraAttribute
  class HydraEntityAttributeAssociation
    class WrongProxyMethodError < ArgumentError
      def initialize(method)
        super("Unknown :#{method} method")
      end
    end

    include ::HydraAttribute::Model::Mediator
    include ::HydraAttribute::Model::IdentityMap

    observe 'HydraAttribute::HydraAttribute', after_create: :hydra_attribute_created, after_update: :hydra_attribute_updated, after_destroy: :hydra_attribute_destroyed

    attr_reader :entity

    class << self
      # Generate hydra attribute methods
      def generate_methods
        ::HydraAttribute::HydraAttribute.all.each do |hydra_attribute|
          add_to_cache(hydra_attribute.entity_type, hydra_attribute.name, hydra_attribute.id)
        end
        identity_map[:___methods_generated___] = true
      end

      # Checks if methods were generated
      def methods_generated?
        identity_map[:___methods_generated___] ||= false
      end

      # Callback
      def hydra_attribute_created(hydra_attribute) # :nodoc:
        return unless methods_generated?
        add_to_cache(hydra_attribute.entity_type, hydra_attribute.name, hydra_attribute.id)
      end

      # Callback
      def hydra_attribute_updated(hydra_attribute) # :nodoc:
        delete_from_cache(hydra_attribute.entity_type_was, hydra_attribute.name_was)
        add_to_cache(hydra_attribute.entity_type, hydra_attribute.name, hydra_attribute.id)
      end

      # Callback
      def hydra_attribute_destroyed(hydra_attribute) # :nodoc:
        delete_from_cache(hydra_attribute.entity_type, hydra_attribute.name)
      end

      private
        def add_to_cache(entity_type, name, id)
          identity_map[entity_type] ||= {names: {}, names_as_hash: {}, ids_as_hash: {}}
          ::ActiveRecord::Base.attribute_method_matchers.each do |matcher|
            current = matcher.method_name(name).to_sym
            proxy   = matcher.method_name(:value)

            identity_map[entity_type][:names][name] ||= []
            identity_map[entity_type][:names][name] << current
            identity_map[entity_type][:names_as_hash][current] = proxy
            identity_map[entity_type][:ids_as_hash][current]   = id
          end
        end

        def delete_from_cache(entity_type, name)
          current_methods = identity_map[entity_type] && identity_map[entity_type][:names][name]
          return unless current_methods
          current_methods.each do |current_method|
            identity_map[entity_type][:names_as_hash].delete(current_method)
            identity_map[entity_type][:ids_as_hash].delete(current_method)
          end
          identity_map[entity_type][:names].delete(name)
        end
    end

    def initialize(entity, hydra_values = {})
      @entity       = entity
      @hydra_values = hydra_values
    end

    def save
      touch = false
      @hydra_values.each do |hydra_attribute_id, hydra_value|
        if has_attribute_id?(hydra_attribute_id)
          hydra_value.save
          touch = true
        end
      end
      entity.touch if touch
    end

    def destroy
      #HydraValue.delete_for(entity.id)
    end

    def has_proxy_method?(method)
      self.class.generate_methods unless self.class.methods_generated?
      identity_map = self.class.identity_map[entity.class.model_name]
      return false unless identity_map
      !!identity_map[:names_as_hash][method.to_sym]
    end

    def delegate(method, *args, &block)
      self.class.generate_methods unless self.class.methods_generated?
      identity_map     = self.class.identity_map[entity.class.model_name] or raise WrongProxyMethodError, method
      attribute_id     = identity_map[:ids_as_hash][method]               or raise WrongProxyMethodError, method
      attribute_method = identity_map[:names_as_hash][method]             or raise WrongProxyMethodError, method

      if has_attribute_id?(attribute_id)
        hydra_value = @hydra_values[attribute_id] ||= HydraValue.new(entity, hydra_attribute_id: attribute_id)
        hydra_value.send(attribute_method, *args, &block)
      else
        raise HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attribute_id} is missed in Set ID #{entity.hydra_set.id}"
      end
    end

    private
      def has_attribute_id?(hydra_attribute_id)
        !entity.hydra_set || entity.hydra_set.has_hydra_attribute_id?(hydra_attribute_id)
      end
  end
end