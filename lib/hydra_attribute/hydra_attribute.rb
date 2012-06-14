module HydraAttribute
  class HydraAttribute < ActiveRecord::Base
    self.table_name = 'hydra_attributes'

    has_and_belongs_to_many :hydra_sets,
                            :class_name              => 'HydraAttribute::HydraSet',
                            :join_table              => 'hydra_attribute_sets',
                            :foreign_key             => 'hydra_attribute_id',
                            :association_foreign_key => 'hydra_set_id'
  end
end