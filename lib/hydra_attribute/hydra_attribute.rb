require 'active_support/core_ext/object/with_options'

module HydraAttribute
  class HydraAttribute < ActiveRecord::Base
    self.table_name = 'hydra_attributes'

    with_options as: [:default, :admin] do |klass|
      klass.attr_accessible :name, :backend_type, :default_value
    end
    attr_accessible :white_list, as: :admin

    has_and_belongs_to_many :hydra_sets, join_table: 'hydra_attribute_sets', class_name: 'HydraAttribute::HydraSet', conditions: proc { {hydra_sets: {entity_type: entity_type}} }

    with_options presence: true do |klass|
      klass.validates :entity_type,  inclusion: { in: lambda { |attr| [(attr.entity_type.constantize.name rescue nil)] } }
      klass.validates :name,         uniqueness: { scope: :entity_type }
      klass.validates :backend_type, inclusion: SUPPORT_TYPES
    end

    before_destroy :delete_dependent_values
    after_commit   :reload_attribute_methods
    after_commit   :toggle_white_list!

    def toggle_white_list!
      if destroyed? or !white_list?
        remove_from_white_list
      else
        add_to_white_list
      end
    end

    private

    def delete_dependent_values
      value_class = AssociationBuilder.class_name(entity_type.constantize, backend_type).constantize
      value_class.delete_all(hydra_attribute_id: id)
    end

    def reload_attribute_methods
      entity_type.constantize.reset_hydra_attribute_methods! # TODO should not remove all generated methods just for this attribute
    end

    def add_to_white_list
      entity_type.constantize.accessible_attributes.add(name)
    end

    def remove_from_white_list
      entity_type.constantize.accessible_attributes.delete(name)
    end
  end
end