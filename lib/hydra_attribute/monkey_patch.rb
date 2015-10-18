module ActiveRecord
  module Associations
    class Association #:nodoc:
      private
      if private_method_defined? :skip_statement_cache?
        alias_method :original_skip_statement_cache?, :skip_statement_cache?
        def skip_statement_cache?
          original_skip_statement_cache? || reflection.klass.include?(::HydraAttribute::ActiveRecord)
        end
      end
    end
  end
end

module ActiveRecord
  module Core
    module ClassMethods #:nodoc:
      alias_method :original_find, :find
      def find(*ids)
        self.ancestors.include?(::HydraAttribute::ActiveRecord) ? super(*ids) : original_find(*ids)
      end
    end
  end
end
