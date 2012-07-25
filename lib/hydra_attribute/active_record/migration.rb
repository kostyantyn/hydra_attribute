module HydraAttribute
  module ActiveRecord
    module Migration
      def create_hydra_entity(name, options = {}, &block)
        Migrator.create(self, name, options, &block)
      end

      def drop_hydra_entity(name)
        Migrator.drop(self, name)
      end

      def migrate_to_hydra_entity(name)
        Migrator.migrate(self, name)
      end

      def rollback_from_hydra_entity(name)
        Migrator.rollback(self, name)
      end
    end
  end
end