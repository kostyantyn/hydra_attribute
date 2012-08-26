require 'active_support/core_ext/object/with_options'

module HydraAttribute
  class HydraSet < ActiveRecord::Base
    self.table_name = 'hydra_sets'

    attr_accessible :name

    has_and_belongs_to_many :hydra_attributes, join_table: 'hydra_attribute_sets', class_name: 'HydraAttribute::HydraAttribute', conditions: proc { {hydra_attributes: {entity_type: entity_type}} }

    with_options presence: true do |klass|
      klass.validates :entity_type,  inclusion: { in: lambda { |attr| [(attr.entity_type.constantize.name rescue nil)] } }
      klass.validates :name,         uniqueness: { scope: :entity_type }
    end

    after_destroy :detach_entities
    after_commit  :clear_entity_cache

  private

    def clear_entity_cache
      entity_type.constantize.clear_hydra_set_cache!
      entity_type.constantize.clear_hydra_attribute_cache!
    end

    def detach_entities
      entity_type.constantize.where(hydra_set_id: id).update_all(hydra_set_id: nil)
    end
  end
end