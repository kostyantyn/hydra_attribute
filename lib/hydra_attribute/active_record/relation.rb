module HydraAttribute
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        include QueryMethods

        target = ::ActiveRecord::VERSION::STRING.starts_with?('3.1.') ? :to_a : :exec_queries
        alias_method :__old_exec_queries__, target
        alias_method target, :__exec_queries__
      end

      def __exec_queries__
        return @records if loaded?
        records = __old_exec_queries__
        return records if records.empty?

        AssociationPreloader.run(self, records)
        records
      end

    end
  end
end