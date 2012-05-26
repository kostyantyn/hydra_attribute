module HydraAttribute
  module ActiveRecord
    module Scoping
      extend ActiveSupport::Concern

      module ClassMethods
        def scoped(options = nil)
          super(options).extend(Relation)
        end
      end
    end
  end
end