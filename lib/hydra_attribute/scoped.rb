module HydraAttribute
  module Scoped
    def scoped(options = nil)
      super(options).extend(HydraAttribute::ActiveRecord::Relation)
    end
  end
end