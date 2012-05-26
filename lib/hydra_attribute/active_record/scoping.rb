module HydraAttribute
  module ActiveRecord
    module Scoping
      def scoped(options = nil)
        super(options).extend(Relation)
      end
    end
  end
end