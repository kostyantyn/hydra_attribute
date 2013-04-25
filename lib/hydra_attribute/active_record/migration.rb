module HydraAttribute
  module ActiveRecord
    module Migration
      def create_hydra_entity(name, options = {}, &block)
        ::HydraAttribute::Migrator.create(self, name, options, &block)
      end

      def drop_hydra_entity(name)
        ::HydraAttribute::Migrator.drop(self, name)
      end

      def migrate_to_hydra_entity(name, options = {}, &block)
        ::HydraAttribute::Migrator.migrate(self, name, options, &block)
      end

      def rollback_from_hydra_entity(name)
        ::HydraAttribute::Migrator.rollback(self, name)
      end
    end
  end
end