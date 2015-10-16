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
