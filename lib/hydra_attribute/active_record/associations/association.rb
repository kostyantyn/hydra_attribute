module HydraAttribute
  module ActiveRecord
    module Associations
      module Association
        extend ActiveSupport::Concern

        def target_scope
          target_scope = super
          target_scope.singleton_class.send(:include, ::HydraAttribute::ActiveRecord::Relation)
          target_scope
        end
      end
    end
  end
end
