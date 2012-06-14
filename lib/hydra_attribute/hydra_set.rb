module HydraAttribute
  class HydraSet < ActiveRecord::Base
    self.table_name = 'hydra_sets'

    has_and_belongs_to_many :hydra_attributes,
                            :class_name              => 'HydraAttribute::HydraAttribute',
                            :join_table              => 'hydra_attribute_sets',
                            :foreign_key             => 'hydra_set_id',
                            :association_foreign_key => 'hydra_attribute_id'
  end
end