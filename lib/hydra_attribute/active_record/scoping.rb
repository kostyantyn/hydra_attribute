module HydraAttribute
  module ActiveRecord
    module Scoping
      extend ActiveSupport::Concern

      module ClassMethods
        def scoped(options = nil)
          p '@' * 20
          relation = super(options)
          relation.singleton_class.send(:include, Relation) unless relation.is_a?(Relation)
          relation
        end
      end
    end
  end
end