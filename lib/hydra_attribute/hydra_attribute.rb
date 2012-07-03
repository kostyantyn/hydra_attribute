require 'active_support/core_ext/object/with_options'

module HydraAttribute
  class HydraAttribute < ActiveRecord::Base
    self.table_name = 'hydra_attributes'

    has_and_belongs_to_many :hydra_sets,
                            :class_name              => 'HydraAttribute::HydraSet',
                            :join_table              => 'hydra_attribute_sets',
                            :foreign_key             => 'hydra_attribute_id',
                            :association_foreign_key => 'hydra_set_id'

    with_options presence: true do |klass|
      klass.validates :entity_type,  inclusion: { in: lambda { |attr| [(attr.entity_type.constantize.name rescue nil)] } }
      klass.validates :name,         uniqueness: { scope: :entity_type }
      klass.validates :backend_type, inclusion: SUPPORT_TYPES + SUPPORT_TYPES.map(&:to_s)
    end

    after_commit :reload_entity_attributes

    private

    def reload_entity_attributes
      entity_type.constantize.undefine_attribute_methods
    end
  end
end