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
      klass.validates :backend_type, inclusion: SUPPORTED_BACKEND_TYPES
    end

    before_destroy :delete_dependent_values
    after_commit   :clear_entity_cache
    after_commit   :update_mass_assignment_security

    # @COMPATIBILITY with 3.1.x association module is directly added to the class instead of including module
    def hydra_sets_with_clearing_cache=(value)
      self.hydra_sets_without_clearing_cache = value
      clear_entity_cache
      value
    end
    alias_method_chain :hydra_sets=, :clearing_cache

    def update_mass_assignment_security
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

      def clear_entity_cache
        entity_type.constantize.clear_hydra_method_cache!
      end

      def add_to_white_list
        entity_type.constantize.accessible_attributes.add(name)
      end

      def remove_from_white_list
        entity_type.constantize.accessible_attributes.delete(name)
      end
  end
end