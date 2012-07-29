require 'active_support/core_ext/object/with_options'

module HydraAttribute
  class HydraAttribute < ActiveRecord::Base
    self.table_name = 'hydra_attributes'

    with_options as: [:default, :admin] do |klass|
      klass.attr_accessible :name, :backend_type, :default_value
    end
    attr_accessible :white_list, as: :admin

    with_options presence: true do |klass|
      klass.validates :entity_type,  inclusion: { in: lambda { |attr| [(attr.entity_type.constantize.name rescue nil)] } }
      klass.validates :name,         uniqueness: { scope: :entity_type }
      klass.validates :backend_type, inclusion: SUPPORT_TYPES
    end

    before_destroy :delete_dependent_values
    after_commit   :reload_entity_attributes

    private

    def delete_dependent_values
      value_class = AssociationBuilder.class_name(entity_type.constantize, backend_type).constantize
      value_class.delete_all(hydra_attribute_id: id)
    end

    def reload_entity_attributes
      entity_type.constantize.reset_hydra_attribute_methods # TODO should not remove all generated methods just for this attribute
      destroyed? ? remove_from_white_list : add_to_white_list
    end

    # Add attribute to white list for entity if it has a white list mark
    def add_to_white_list
      entity_type.constantize.accessible_attributes.add(name) if white_list?
    end

    # Don't check if this attribute is in white list or has a white list mark.
    # Just remove it from white list for entity
    def remove_from_white_list
      entity_type.constantize.accessible_attributes.remove(name)
    end
  end
end